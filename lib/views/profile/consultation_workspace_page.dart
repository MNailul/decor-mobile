import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/consultation_model.dart';
import '../../providers/consultation_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/designer_provider.dart';
import '../designer/designer_booking_page.dart';
import 'package:image_picker/image_picker.dart';
import '../designer/consultation_payment_page.dart';
import '../../core/utils/currency_formatter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';
import '../../widgets/bounce_tap.dart';
import 'track_consultation_page.dart';
import 'designer_contact_info_page.dart';

class ConsultationWorkspacePage extends StatefulWidget {
  final ConsultationModel consultation;

  const ConsultationWorkspacePage({super.key, required this.consultation});

  @override
  State<ConsultationWorkspacePage> createState() => _ConsultationWorkspacePageState();
}

class _ConsultationWorkspacePageState extends State<ConsultationWorkspacePage> {
  late ConsultationModel currentConsultation;
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _revisionController = TextEditingController();
  bool _isLoading = false;

  Timer? _pollingTimer;
  Timer? _countdownTimer;
  int _timeLeft = 0;
  bool _isTimeUp = false;

  static const Color primaryColor = Color(0xFFB5733A);
  static const Color textColor = Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    currentConsultation = widget.consultation;
    _refreshData();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _refreshDataSilently();
    });
  }

  Future<void> _refreshDataSilently() async {
    final detail = await context.read<ConsultationProvider>().getConsultationDetail(widget.consultation.id);
    if (detail != null && mounted) {
      setState(() {
        currentConsultation = detail;
      });
      // Optionally start countdown if needed
      if (currentConsultation.status == 0 && currentConsultation.chatExpiresAt != null) {
        final difference = currentConsultation.chatExpiresAt!.difference(DateTime.now()).inSeconds;
        if (difference > 0 && _countdownTimer == null) {
          _startCountdownIfNeeded();
        }
      }
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();
    _messageController.dispose();
    _revisionController.dispose();
    super.dispose();
  }

  void _startCountdownIfNeeded() {
    _countdownTimer?.cancel();
    if (currentConsultation.consultationType == 'chat_consultation' && 
        currentConsultation.chatExpiresAt != null) {
      
      final now = DateTime.now();
      final difference = currentConsultation.chatExpiresAt!.difference(now).inSeconds;
      
      if (difference > 0) {
        setState(() {
          _timeLeft = difference;
          _isTimeUp = false;
        });
        
        _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_timeLeft > 0) {
            setState(() {
              _timeLeft--;
            });
          } else {
            timer.cancel();
            setState(() {
              _isTimeUp = true;
            });
            _showTimeUpModal();
          }
        });
      } else {
        setState(() {
          _timeLeft = 0;
          _isTimeUp = true;
        });
      }
    }
  }

  void _showTimeUpModal() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.timer_off_outlined, color: Colors.red, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                'Waktu Habis!',
                style: GoogleFonts.epilogue(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Sesi chat konsultasi 30 menit Anda dengan ${currentConsultation.designerName ?? 'Desainer'} telah berakhir. Silakan lakukan pemesanan baru untuk melanjutkan.',
                textAlign: TextAlign.center,
                style: GoogleFonts.epilogue(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    // Show progress loader
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator(color: primaryColor)),
                    );
                    
                    try {
                      final designer = await context.read<DesignerProvider>().getDesignerDetail(currentConsultation.designerId);
                      Navigator.pop(context); // Close loading indicator
                      if (designer != null) {
                        Navigator.pop(context); // Close time-up modal
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DesignerBookingPage(designer: designer),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to load designer details.')),
                        );
                      }
                    } catch (_) {
                      Navigator.pop(context); // Close loading indicator
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to load designer details.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'BOOK CONSULTATION',
                    style: GoogleFonts.epilogue(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back
                },
                child: Text(
                  'KEMBALI KE PROFIL',
                  style: GoogleFonts.epilogue(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String get timerString {
    int minutes = _timeLeft ~/ 60;
    int seconds = _timeLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _refreshData() async {
    final detail = await context.read<ConsultationProvider>().getConsultationDetail(widget.consultation.id);
    if (detail != null && mounted) {
      setState(() {
        currentConsultation = detail;
      });
      _startCountdownIfNeeded();
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final msg = _messageController.text;
    _messageController.clear();

    final success = await context.read<ConsultationProvider>().sendMessage(currentConsultation.id, msg);
    if (success) {
      _refreshData();
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _isLoading = true);
      final success = await context.read<ConsultationProvider>().uploadAttachment(
            currentConsultation.id,
            image.path,
            'image',
          );
      setState(() => _isLoading = false);

      if (success) {
        _refreshData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image')),
        );
      }
    }
  }

  Future<void> _downloadInvoice() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/consultation/invoice/${currentConsultation.id}');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open invoice URL')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final userId = int.tryParse(authProvider.currentUser?.id ?? '');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DesignerContactInfoPage(consultation: currentConsultation)),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: currentConsultation.fullDesignerImage != null ? NetworkImage(currentConsultation.fullDesignerImage!) : null,
                child: currentConsultation.fullDesignerImage == null ? const Icon(Icons.person, size: 20, color: Colors.grey) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentConsultation.designerName ?? 'Designer',
                      style: GoogleFonts.epilogue(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      currentConsultation.consultationType == 'chat_consultation' ? 'Chat Consultation' : 'Project Consultation',
                      style: GoogleFonts.epilogue(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (currentConsultation.consultationType == 'chat_consultation' && 
              currentConsultation.chatExpiresAt != null && 
              !_isTimeUp && 
              !currentConsultation.isChatExpired)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _timeLeft <= 60 ? Colors.red.shade50 : primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _timeLeft <= 60 ? Colors.red.shade100 : primaryColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, size: 12, color: _timeLeft <= 60 ? Colors.red : primaryColor),
                  const SizedBox(width: 4),
                  Text(
                    timerString,
                    style: GoogleFonts.epilogue(
                      fontWeight: FontWeight.w900,
                      color: _timeLeft <= 60 ? Colors.red : primaryColor,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          IconButton(
            icon: const Icon(Icons.description_outlined, color: textColor, size: 20),
            onPressed: _downloadInvoice,
            tooltip: 'Download Invoice',
          ),
        ],
      ),
      body: Column(
        children: [


          // Chat View directly
          Expanded(
            child: Stack(
              children: [
                _buildChatTab(userId),
                
                // Action Required Overlay
                if ([0, 5, 7, 8, 9].contains(currentConsultation.status))
                  _buildActionRequiredOverlay(),
              ],
            ),
          ),

          // Message Input
          if ([1, 2, 3, 7, 8, 9].contains(currentConsultation.status) && !_isTimeUp && !currentConsultation.isChatExpired)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.attach_file, color: Colors.grey.shade600),
                      onPressed: _pickImage,
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: GoogleFonts.epilogue(fontSize: 14, color: Colors.grey),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      backgroundColor: primaryColor,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 20),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (currentConsultation.status == 4)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline_rounded, color: Colors.green.shade700, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'PROYEK SELESAI. CHAT TELAH DINONAKTIFKAN.',
                      style: GoogleFonts.epilogue(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (_isTimeUp || currentConsultation.isChatExpired)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline_rounded, color: Colors.red.shade700, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'WAKTU KONSULTASI HABIS. CHAT TELAH DINONAKTIFKAN.',
                      style: GoogleFonts.epilogue(
                        color: Colors.red.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  bool _hideOverlay = false;

  Widget _buildActionRequiredOverlay() {
    if (_hideOverlay) return const SizedBox.shrink();
    
    String message = '';
    if (currentConsultation.status == 7) {
      if (currentConsultation.paymentProof != null) return const SizedBox.shrink();
      message = 'Harap unggah bukti pembayaran fee konsultasi.';
    }
    else if (currentConsultation.status == 0) message = 'Pembayaran divalidasi! Harap isi brief ruangan Anda.';
    else if (currentConsultation.status == 8) message = 'Desainer telah mengirimkan RAB (Penawaran Harga) untuk direview.';
    else if (currentConsultation.status == 9) {
      if (currentConsultation.paymentProof != null) return const SizedBox.shrink();
      message = 'RAB disetujui! Harap unggah bukti pembayaran akhir.';
    }
    else if (currentConsultation.status == 5) message = 'Menunggu persetujuan desainer atas request Anda.';

    return Container(
      color: Colors.white.withOpacity(0.7),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.notifications_active_outlined, color: primaryColor, size: 32),
              ),
              const SizedBox(height: 20),
              Text('Tindakan Diperlukan', style: GoogleFonts.epilogue(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center, style: GoogleFonts.epilogue(fontSize: 13, color: Colors.grey.shade600, height: 1.5)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to TrackConsultationPage
                    Navigator.pop(context); // Close workspace and go back to profile maybe?
                    // Better to just push the Track page
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackConsultationPage()));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text('BUKA TRACK CONSULTATION', style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setState(() => _hideOverlay = true),
                child: Text('NANTI SAJA', style: GoogleFonts.epilogue(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatTab(int? userId) {
    List<dynamic> items = [];
    if (currentConsultation.messages != null) items.addAll(currentConsultation.messages!);
    if (currentConsultation.attachments != null) items.addAll(currentConsultation.attachments!);
    if (currentConsultation.quotes != null) {
      items.addAll(currentConsultation.quotes!);
    }
    
    // Sort by created_at
    items.sort((a, b) {
      DateTime getCreated(dynamic item) {
        if (item is ConsultationMessageModel) return item.createdAt;
        if (item is ConsultationAttachmentModel) return item.createdAt;
        if (item is ConsultationQuoteModel) return item.createdAt ?? DateTime.now();
        return DateTime.now();
      }
      return getCreated(a).compareTo(getCreated(b));
    });

    List<dynamic> groupedItems = [];
    List<ConsultationAttachmentModel> currentImageGroup = [];

    for (var item in items) {
      if (item is ConsultationAttachmentModel) {
        bool isImage = item.fileType.toLowerCase().contains('png') || 
                       item.fileType.toLowerCase().contains('jpg') || 
                       item.fileType.toLowerCase().contains('jpeg') ||
                       item.fileType.toLowerCase().contains('webp') ||
                       item.fileType.toLowerCase().contains('image');
        if (isImage) {
          if (currentImageGroup.isEmpty) {
            currentImageGroup.add(item);
          } else {
            if (currentImageGroup.last.uploadedBy == item.uploadedBy) {
              currentImageGroup.add(item);
            } else {
              if (currentImageGroup.length == 1) {
                groupedItems.add(currentImageGroup.first);
              } else {
                groupedItems.add(List<ConsultationAttachmentModel>.from(currentImageGroup));
              }
              currentImageGroup = [item];
            }
          }
        } else {
          if (currentImageGroup.isNotEmpty) {
            if (currentImageGroup.length == 1) {
              groupedItems.add(currentImageGroup.first);
            } else {
              groupedItems.add(List<ConsultationAttachmentModel>.from(currentImageGroup));
            }
            currentImageGroup = [];
          }
          groupedItems.add(item);
        }
      } else {
        if (currentImageGroup.isNotEmpty) {
          if (currentImageGroup.length == 1) {
            groupedItems.add(currentImageGroup.first);
          } else {
            groupedItems.add(List<ConsultationAttachmentModel>.from(currentImageGroup));
          }
          currentImageGroup = [];
        }
        groupedItems.add(item);
      }
    }
    if (currentImageGroup.isNotEmpty) {
      if (currentImageGroup.length == 1) {
        groupedItems.add(currentImageGroup.first);
      } else {
        groupedItems.add(currentImageGroup);
      }
    }

    if (groupedItems.isEmpty) {
      return Center(
        child: Text(
          'No messages yet.\nStart the conversation!',
          textAlign: TextAlign.center,
          style: GoogleFonts.epilogue(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: groupedItems.length,
      itemBuilder: (context, index) {
        final item = groupedItems[index];
        
        if (item is List<ConsultationAttachmentModel>) {
          bool isMe = item.first.uploadedBy == userId;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!isMe)
                  const CircleAvatar(
                    radius: 15,
                    backgroundColor: secondaryColor,
                    child: Icon(Icons.person, size: 15, color: Colors.white),
                  ),
                const SizedBox(width: 8),
                Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isMe ? primaryColor.withOpacity(0.05) : Colors.white,
                    border: Border.all(color: isMe ? primaryColor.withOpacity(0.2) : Colors.grey.shade200),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMe ? 20 : 0),
                      bottomRight: Radius.circular(isMe ? 0 : 20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.65,
                          child: GridView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: item.length == 2 || item.length == 4 ? 2 : (item.length >= 3 ? 3 : 2),
                              crossAxisSpacing: 4,
                              mainAxisSpacing: 4,
                            ),
                            itemCount: item.length > 4 ? 4 : item.length,
                            itemBuilder: (context, gridIndex) {
                              final imgUrl = item[gridIndex].fullUrl;
                              if (gridIndex == 3 && item.length > 4) {
                                return GestureDetector(
                                  onTap: () => _openImageSlider(context, item, gridIndex),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(imgUrl, fit: BoxFit.cover),
                                      Container(color: Colors.black.withOpacity(0.5)),
                                      Center(
                                        child: Text('+${item.length - 4}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return GestureDetector(
                                onTap: () => _openImageSlider(context, item, gridIndex),
                                child: Image.network(imgUrl, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.broken_image)),
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8, bottom: 4, top: 4),
                        child: Text(
                          '${item.last.createdAt.hour}:${item.last.createdAt.minute.toString().padLeft(2, '0')}',
                          style: GoogleFonts.epilogue(color: Colors.grey, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        if (item is ConsultationAttachmentModel) {
          bool isMe = item.uploadedBy == userId;
          bool isImage = item.fileType.toLowerCase().contains('png') || 
                         item.fileType.toLowerCase().contains('jpg') || 
                         item.fileType.toLowerCase().contains('jpeg') ||
                         item.fileType.toLowerCase().contains('webp') ||
                         item.fileType.toLowerCase().contains('image');

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!isMe)
                  const CircleAvatar(
                    radius: 15,
                    backgroundColor: secondaryColor,
                    child: Icon(Icons.person, size: 15, color: Colors.white),
                  ),
                const SizedBox(width: 8),
                Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe ? primaryColor.withOpacity(0.05) : Colors.white,
                    border: Border.all(color: isMe ? primaryColor.withOpacity(0.2) : Colors.grey.shade200),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMe ? 20 : 0),
                      bottomRight: Radius.circular(isMe ? 0 : 20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isImage)
                        GestureDetector(
                          onTap: () => _openImageSlider(context, [item], 0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              item.fullUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
                              },
                            ),
                          ),
                        )
                      else
                        InkWell(
                          onTap: () async {
                            final url = Uri.parse(item.fullUrl);
                            if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Could not open file')),
                                );
                              }
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.picture_as_pdf, color: Colors.red, size: 32),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'RAB / Attachment File',
                                      style: GoogleFonts.epilogue(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    Text(
                                      'Tap to download/view',
                                      style: GoogleFonts.epilogue(fontSize: 10, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        '${item.createdAt.hour}:${item.createdAt.minute.toString().padLeft(2, '0')}',
                        style: GoogleFonts.epilogue(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        
        if (item is ConsultationMessageModel) {
          bool isMe = item.senderId == userId;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!isMe)
                  const CircleAvatar(
                    radius: 15,
                    backgroundColor: secondaryColor,
                    child: Icon(Icons.person, size: 15, color: Colors.white),
                  ),
                const SizedBox(width: 8),
                Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isMe ? primaryColor : Colors.white,
                    border: isMe ? null : Border.all(color: Colors.grey.shade100),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMe ? 20 : 0),
                      bottomRight: Radius.circular(isMe ? 0 : 20),
                    ),
                    boxShadow: isMe ? null : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.message,
                        style: GoogleFonts.epilogue(
                          color: isMe ? Colors.white : textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.createdAt.hour}:${item.createdAt.minute.toString().padLeft(2, '0')}',
                        style: GoogleFonts.epilogue(
                          color: isMe ? Colors.white.withOpacity(0.6) : Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }



  Widget _buildAssetsTab() {
    if (currentConsultation.attachments == null || currentConsultation.attachments!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 48, color: Colors.grey.shade200),
            const SizedBox(height: 16),
            Text(
              'No assets uploaded yet.',
              style: GoogleFonts.epilogue(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: currentConsultation.attachments!.length,
      itemBuilder: (context, index) {
        final asset = currentConsultation.attachments![index];
        bool isImage = asset.fileType.contains('image');

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                if (isImage)
                  Image.network(
                    asset.fullUrl, 
                    width: double.infinity, 
                    height: double.infinity, 
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator(value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null));
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(child: Icon(Icons.broken_image, color: Colors.red.shade200, size: 32));
                    },
                  )
                else
                  Center(child: Icon(Icons.insert_drive_file, size: 32, color: Colors.grey.shade300)),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: Colors.black.withOpacity(0.6),
                    child: Text(
                      asset.fileUrl.split('/').last,
                      style: GoogleFonts.epilogue(color: Colors.white, fontSize: 8),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  void _openImageSlider(BuildContext context, List<ConsultationAttachmentModel> images, int initialIndex) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: PageView.builder(
          itemCount: images.length,
          controller: PageController(initialPage: initialIndex),
          itemBuilder: (context, index) {
            return Center(
              child: InteractiveViewer(
                child: Image.network(images[index].fullUrl),
              ),
            );
          },
        ),
      );
    }));
  }
  
  static const Color secondaryColor = Color(0xFFE3DCD6);
}
