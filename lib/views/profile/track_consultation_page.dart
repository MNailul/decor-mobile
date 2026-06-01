import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:convert';
import '../../providers/consultation_provider.dart';
import '../../models/consultation_model.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/constants.dart';
import '../../core/theme/app_colors.dart';
import '../designer/consultation_payment_page.dart';
import 'consultation_workspace_page.dart';

class TrackConsultationPage extends StatefulWidget {
  const TrackConsultationPage({super.key});

  @override
  State<TrackConsultationPage> createState() => _TrackConsultationPageState();
}

class _TrackConsultationPageState extends State<TrackConsultationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _briefController = TextEditingController();
  final TextEditingController _revisionController = TextEditingController();
  int? _rating;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  bool _isLoading = false;
  Timer? _pollingTimer;

  static const Color primaryColor = Color(0xFFB5733A);
  static const Color textColor = Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConsultationProvider>().loadConsultations();
    });
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        context.read<ConsultationProvider>().loadConsultations();
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _tabController.dispose();
    _briefController.dispose();
    _revisionController.dispose();
    _commentController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  List<ConsultationModel> _getFilteredConsultations(List<ConsultationModel> consultations, int tabIndex) {
    switch (tabIndex) {
      case 0: // Semua
        return consultations;
      case 1: // Menunggu Pembayaran
        return consultations.where((c) => c.status == 7 || c.status == 9).toList();
      case 2: // Aktif / Berjalan
        return consultations.where((c) => [0, 1, 2, 3, 5, 8].contains(c.status)).toList();
      case 3: // Selesai
        return consultations.where((c) => c.status == 4).toList();
      case 4: // Dibatalkan
        return consultations.where((c) => c.status == 6).toList();
      default:
        return consultations;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Track Consultations',
          style: GoogleFonts.epilogue(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey.shade400,
          indicatorColor: primaryColor,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: const [
            Tab(text: 'SEMUA'),
            Tab(text: 'MENUNGGU PEMBAYARAN'),
            Tab(text: 'AKTIF / BERJALAN'),
            Tab(text: 'SELESAI'),
            Tab(text: 'DIBATALKAN'),
          ],
        ),
      ),
      body: Consumer<ConsultationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }

          return TabBarView(
            controller: _tabController,
            children: List.generate(5, (index) {
              final list = _getFilteredConsultations(provider.consultations, index);
              if (list.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (context, idx) {
                  return _buildTrackingCard(context, list[idx], provider);
                },
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Tidak ada konsultasi',
            style: GoogleFonts.epilogue(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingCard(BuildContext context, ConsultationModel consultation, ConsultationProvider provider) {
    final bool isCompleted = consultation.status == 4;
    final bool isActive = [1, 2, 3, 4, 8, 9].contains(consultation.status);
    final bool isReview = [2, 3, 4, 8, 9].contains(consultation.status);
    final bool canChat = ![0, 5, 6, 7].contains(consultation.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: consultation.getStatusColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          consultation.getStatusLabel().toUpperCase(),
                          style: GoogleFonts.epilogue(
                            color: consultation.getStatusColor(),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Konsultasi #${consultation.id}',
                        style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Designer: ${consultation.designerName ?? 'Expert'}',
                        style: GoogleFonts.epilogue(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: canChat ? () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => ConsultationWorkspacePage(consultation: consultation)));
                      } : null,
                      icon: const Icon(Icons.chat_bubble_outline, size: 16),
                      label: const Text('Chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canChat ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
                        foregroundColor: canChat ? Colors.white : Colors.grey.shade400,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    if (isCompleted) ...[
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => _showReviewDialog(context, consultation),
                        icon: const Icon(Icons.star, size: 16),
                        label: const Text('Beri Ulasan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade500,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ]
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Body layout: Timeline + Actions
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CONSULTATION STATUS',
                  style: GoogleFonts.epilogue(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1.5),
                ),
                const SizedBox(height: 16),
                
                // Timeline
                _buildTimelineStep('Setup', 'Permintaan dibuat', true, true, isCompleted),
                _buildTimelineStep('Active', 'Sedang berjalan', isActive, true, isCompleted),
                _buildTimelineStep('Review', 'Penawaran RAB & Review', isReview, true, isCompleted),
                _buildTimelineStep('Done', 'Proyek Selesai', isCompleted, false, isCompleted),

                const SizedBox(height: 24),
                const Divider(height: 1),
                const SizedBox(height: 24),

                Text(
                  'ACTION & DETAILS',
                  style: GoogleFonts.epilogue(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1.5),
                ),
                const SizedBox(height: 12),

                // Details Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(consultation.title, style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(consultation.description.isNotEmpty ? consultation.description : 'No brief description provided.', 
                           style: GoogleFonts.epilogue(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Dynamic Actions
                _buildDynamicActions(context, consultation, provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String title, String subtitle, bool isActive, bool isNotLast, bool isCompleted) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? primaryColor : Colors.grey.shade200,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: isActive ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
              ),
              if (isNotLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: (isActive && isCompleted) || (isActive && title != 'Review' && title != 'Active') ? primaryColor : Colors.grey.shade100,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.epilogue(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isActive ? textColor : Colors.grey.shade400,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.epilogue(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicActions(BuildContext context, ConsultationModel consultation, ConsultationProvider provider) {
    final status = consultation.status;

    if (status == 7) { // Waiting Consultation Fee
      if (consultation.paymentProof != null) {
        return _buildStatusAlert(Icons.access_time, 'Bukti Pembayaran Fee Dikirim. Menunggu Verifikasi.', Colors.amber);
      } else {
        return _buildPaymentButton(
          context: context,
          consultation: consultation,
          label: 'BAYAR FEE: ${consultation.consultationFee.toIDR()}',
          consultationType: consultation.consultationType == 'request_proposal' ? 'Proposal' : 'Chat',
          totalPrice: consultation.consultationFee,
        );
      }
    }

    if (status == 5) { // Waiting Approval
      return _buildStatusAlert(Icons.hourglass_empty, 'Menunggu Approval Desainer', Colors.orange);
    }

    if (status == 0) { // Waiting Brief
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Isi Brief Proyek', style: GoogleFonts.epilogue(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1)),
            const SizedBox(height: 8),
            TextField(
              controller: _briefController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Detail ruangan, preferensi warna...',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_briefController.text.isEmpty) return;
                  setState(() => _isLoading = true);
                  await provider.submitBrief(consultation.id, _briefController.text);
                  setState(() => _isLoading = false);
                },
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white)) : Text('SUBMIT BRIEF', style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ],
        ),
      );
    }

    if (status == 8 || status == 2 || status == 9) { // Offer Received / Under Review / Waiting Final Payment
      final quote = consultation.quotes?.isNotEmpty == true ? consultation.quotes!.first : null;
      if (quote != null && quote.status != 'revision') {
        return _buildQuoteCard(context, quote, consultation, provider);
      }
    }

    return const SizedBox.shrink();
  }

  Widget _buildStatusAlert(IconData icon, String message, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: color.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: color.shade200)),
      child: Row(
        children: [
          Icon(icon, color: color.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: GoogleFonts.epilogue(fontSize: 10, fontWeight: FontWeight.bold, color: color.shade800, letterSpacing: 0.5))),
        ],
      ),
    );
  }

  Widget _buildPaymentButton({required BuildContext context, required ConsultationModel consultation, required String label, required String consultationType, required double totalPrice}) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConsultationPaymentPage(
              designer: {
                'id': consultation.designerId,
                'name': consultation.designerName,
                'image': consultation.fullDesignerImage,
              },
              consultationType: consultationType,
              date: DateTime.now(),
              time: 'Now',
              totalPrice: totalPrice,
              consultationId: consultation.id,
            ),
          ),
        ).then((_) => context.read<ConsultationProvider>().loadConsultations());
      },
      style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), minimumSize: const Size(double.infinity, 50)),
      child: Text(label, style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildQuoteCard(BuildContext context, ConsultationQuoteModel quote, ConsultationModel consultation, ConsultationProvider provider) {
    bool isRevisionVisible = false;

    return StatefulBuilder(
      builder: (context, setStateLocal) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primaryColor.withOpacity(0.3), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PROJECT AGREEMENT & RAB', style: GoogleFonts.epilogue(fontSize: 11, fontWeight: FontWeight.bold, color: primaryColor, letterSpacing: 1)),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Design Fee', style: GoogleFonts.epilogue(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade400, letterSpacing: 1)),
                      Text(quote.amount.toIDR(), style: GoogleFonts.epilogue(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor, fontStyle: FontStyle.italic)),
                    ],
                  ),
                  Row(
                    children: [
                      if (quote.items != null)
                        IconButton(
                          icon: const Icon(Icons.file_download, color: Colors.amber),
                          onPressed: () async {
                            final url = Uri.parse('${ApiConstants.baseUrl}/consultation/quote/${quote.id}/download-rab/public');
                            if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open RAB File')));
                            }
                          },
                          tooltip: 'Download RAB',
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (consultation.status == 8 || consultation.status == 2) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          setStateLocal(() => _isLoading = true);
                          await provider.respondToQuote(quote.id, 'accepted');
                          setStateLocal(() => _isLoading = false);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: _isLoading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white)) : Text('Accept', style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setStateLocal(() => isRevisionVisible = !isRevisionVisible);
                        },
                        style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey.shade300), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: Text('Revision', style: GoogleFonts.epilogue(color: Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
                if (isRevisionVisible) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _revisionController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Tulis catatan revisi...',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_revisionController.text.trim().isEmpty) return;
                        setStateLocal(() => _isLoading = true);
                        await provider.respondToQuote(quote.id, 'revision', revisionNotes: _revisionController.text);
                        setStateLocal(() => _isLoading = false);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: textColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: Text('Kirim Revisi', style: GoogleFonts.epilogue(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ] else if (consultation.status == 9) ...[
                if (consultation.paymentProof != null)
                  _buildStatusAlert(Icons.access_time, 'Bukti Pembayaran Akhir Dikirim. Menunggu Verifikasi.', Colors.amber)
                else
                  _buildPaymentButton(
                    context: context,
                    consultation: consultation,
                    label: 'BAYAR AKHIR: ${quote.amount.toIDR()}',
                    consultationType: 'Project Implementation',
                    totalPrice: quote.amount,
                  ),
              ],
            ],
          ),
        );
      }
    );
  }

  void _showReviewDialog(BuildContext context, ConsultationModel consultation) {
    _rating = 5;
    _durationController.text = '1-3 Months';
    _commentController.clear();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 24),
                    Text('Beri Ulasan Desainer', style: GoogleFonts.epilogue(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 8),
                    Text('Bagaimana pengalaman Anda dengan ${consultation.designerName}?', style: GoogleFonts.epilogue(fontSize: 14, color: Colors.grey.shade600)),
                    const SizedBox(height: 24),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < (_rating ?? 5) ? Icons.star_rounded : Icons.star_outline_rounded,
                              size: 40,
                              color: index < (_rating ?? 5) ? Colors.amber.shade500 : Colors.grey.shade300,
                            ),
                            onPressed: () {
                              setStateModal(() { _rating = index + 1; });
                            },
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Lama Pengerjaan Projek', style: GoogleFonts.epilogue(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        filled: true, fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      value: '1-3 Months',
                      items: ['1-3 Months', '1-6 Months', '1-9 Months', '1-12 Months'].map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value, style: GoogleFonts.epilogue(fontSize: 14)));
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) _durationController.text = newValue;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('Komentar', style: GoogleFonts.epilogue(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _commentController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Ceritakan hasil desain dan pelayanan desainer...',
                        filled: true, fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_commentController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Komentar tidak boleh kosong')));
                            return;
                          }
                          String duration = _durationController.text.isEmpty ? '1 - 3 Bulan' : _durationController.text;
                          final success = await context.read<ConsultationProvider>().submitConsultationReview(
                            consultation.id, _rating ?? 5, _commentController.text, duration,
                          );
                          if (success && context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ulasan berhasil dikirim!')));
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: Text('Kirim Ulasan', style: GoogleFonts.epilogue(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
