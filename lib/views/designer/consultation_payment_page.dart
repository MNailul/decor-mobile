import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import '../../models/consultation_model.dart';
import '../../providers/consultation_provider.dart';
import '../profile/consultation_history_page.dart';
import '../../core/utils/currency_formatter.dart';

class ConsultationPaymentPage extends StatefulWidget {
  final Map<String, dynamic> designer;
  final String consultationType;
  final DateTime date;
  final String time;
  final double totalPrice;
  final String? projectBrief;
  final int? consultationId;

  const ConsultationPaymentPage({
    super.key,
    required this.designer,
    required this.consultationType,
    required this.date,
    required this.time,
    required this.totalPrice,
    this.projectBrief,
    this.consultationId,
  });

  @override
  State<ConsultationPaymentPage> createState() => _ConsultationPaymentPageState();
}

class _ConsultationPaymentPageState extends State<ConsultationPaymentPage> {
  static const Color primaryColor = Color(0xFFB5733A);
  static const Color secondaryColor = Color(0xFFE3DCD6);
  static const Color textColor = Color(0xFF1E1E1E);
  static const Color lightTextColor = Color(0xFF757575);

  File? _proofImage;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickProofImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Pilih Sumber Foto',
                style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFF5EEE8),
                  child: Icon(Icons.camera_alt_rounded, color: primaryColor),
                ),
                title: Text('Kamera', style: GoogleFonts.epilogue(fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFF5EEE8),
                  child: Icon(Icons.photo_library_rounded, color: primaryColor),
                ),
                title: Text('Galeri', style: GoogleFonts.epilogue(fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (image != null && mounted) {
      setState(() => _proofImage = File(image.path));
    }
  }

  Future<void> _submitProof() async {
    if (_proofImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Silakan pilih foto bukti pembayaran terlebih dahulu.',
            style: GoogleFonts.epilogue(),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final consultationProvider = context.read<ConsultationProvider>();
      bool success = false;

      if (widget.consultationId != null) {
        success = await consultationProvider.payConsultation(
          widget.consultationId!,
          _proofImage!.path,
        );
      } else {
        // Booking flow: first create consultation, then (future) pay
        success = await consultationProvider.bookConsultation(
          designerId: widget.designer['id'],
          title: '${widget.consultationType} Consultation',
          description: widget.projectBrief ?? 'No brief provided',
          budgetRange: widget.totalPrice.toString(),
        );
      }

      if (!mounted) return;
      setState(() => _isUploading = false);

      if (success) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          isDismissible: false,
          builder: (context) => SuccessBottomSheet(amount: widget.totalPrice),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              consultationProvider.errorMessage ?? 'Gagal mengunggah bukti pembayaran.',
              style: GoogleFonts.epilogue(),
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}', style: GoogleFonts.epilogue()),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isFinalPayment = widget.consultationType.contains('Project');

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
        title: Text(
          'KIRIM BUKTI PEMBAYARAN',
          style: GoogleFonts.epilogue(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Summary Card ───
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: secondaryColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFinalPayment ? 'PEMBAYARAN PROYEK' : 'CONSULTATION FEE',
                      style: GoogleFonts.epilogue(
                        color: lightTextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.designer['image'] ??
                                'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?q=80&w=200',
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 56,
                              height: 56,
                              color: secondaryColor,
                              child: const Icon(Icons.person, color: lightTextColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.designer['name'] ?? widget.designer['studio_name'] ?? 'Designer',
                                style: GoogleFonts.epilogue(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                '${widget.consultationType} Consultation',
                                style: GoogleFonts.epilogue(color: lightTextColor, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: secondaryColor, thickness: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isFinalPayment ? 'Total Proyek' : 'Consultation Fee',
                          style: GoogleFonts.epilogue(color: lightTextColor, fontSize: 14),
                        ),
                        Text(
                          widget.totalPrice.toIDR(),
                          style: GoogleFonts.epilogue(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    if (!isFinalPayment) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Biaya ini adalah komitmen awal. Biaya jasa desain lengkap akan dinegosiasikan bersama desainer.',
                          style: GoogleFonts.epilogue(
                            fontSize: 10,
                            color: Colors.amber.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ─── Transfer Info ───
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INFORMASI TRANSFER',
                    style: GoogleFonts.epilogue(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: secondaryColor),
                    ),
                    child: Column(
                      children: [
                        _buildTransferRow('Bank', 'BCA'),
                        const SizedBox(height: 12),
                        _buildTransferRow('No. Rekening', '1234 5678 90'),
                        const SizedBox(height: 12),
                        _buildTransferRow('Atas Nama', 'PT Decor Indonesia'),
                        const SizedBox(height: 12),
                        _buildTransferRow('Jumlah', widget.totalPrice.toIDR(), isHighlight: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ─── Upload Proof Section ───
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'UPLOAD BUKTI PEMBAYARAN',
                    style: GoogleFonts.epilogue(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Upload screenshot atau foto struk transfer Anda.',
                    style: GoogleFonts.epilogue(color: lightTextColor, fontSize: 12),
                  ),
                  const SizedBox(height: 16),

                  // Preview / Picker
                  GestureDetector(
                    onTap: _pickProofImage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _proofImage != null ? Colors.transparent : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _proofImage != null ? primaryColor : secondaryColor,
                          width: _proofImage != null ? 2 : 1.5,
                          style: _proofImage != null ? BorderStyle.solid : BorderStyle.solid,
                        ),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: _proofImage != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(_proofImage!, fit: BoxFit.cover),
                                Positioned(
                                  bottom: 10,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.edit, color: Colors.white, size: 14),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Ganti Foto',
                                          style: GoogleFonts.epilogue(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5EEE8),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: const Icon(Icons.cloud_upload_rounded, color: primaryColor, size: 30),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'Tap untuk upload foto',
                                  style: GoogleFonts.epilogue(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'JPG, PNG • Maks. 10 MB',
                                  style: GoogleFonts.epilogue(fontSize: 11, color: lightTextColor),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),

      // ─── Bottom Submit Bar ───
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _submitProof,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _proofImage != null ? primaryColor : Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    disabledBackgroundColor: Colors.grey.shade200,
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.upload_file_rounded, size: 18),
                            const SizedBox(width: 10),
                            Text(
                              'KIRIM BUKTI PEMBAYARAN',
                              style: GoogleFonts.epilogue(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pembayaran akan dikonfirmasi setelah desainer memverifikasi bukti Anda.',
                style: GoogleFonts.epilogue(fontSize: 10, color: lightTextColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransferRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.epilogue(color: lightTextColor, fontSize: 13)),
        Text(
          value,
          style: GoogleFonts.epilogue(
            fontWeight: FontWeight.bold,
            fontSize: isHighlight ? 16 : 13,
            color: isHighlight ? primaryColor : textColor,
          ),
        ),
      ],
    );
  }
}

class SuccessBottomSheet extends StatelessWidget {
  final double amount;
  const SuccessBottomSheet({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFB5733A);
    const Color textColor = Color(0xFF1E1E1E);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 120,
            height: 120,
            child: Lottie.asset('assets/animations/success.json', repeat: false, animate: true),
          ),
          const SizedBox(height: 24),
          Text(
            'Bukti Dikirim!',
            style: GoogleFonts.epilogue(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Bukti pembayaran sebesar ${amount.toIDR()} telah terkirim.\nMenunggu verifikasi dari desainer.',
            style: GoogleFonts.epilogue(
              color: Colors.grey.shade600,
              fontSize: 13,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ConsultationHistoryPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Lihat Status Konsultasi',
                style: GoogleFonts.epilogue(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: primaryColor),
                foregroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Kembali ke Beranda',
                style: GoogleFonts.epilogue(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
