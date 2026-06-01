import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/bounce_tap.dart';

class ReturnRequestPage extends StatefulWidget {
  final ProductModel? product;
  final String orderId;

  const ReturnRequestPage({
    super.key,
    required this.product,
    required this.orderId,
  });

  @override
  State<ReturnRequestPage> createState() => _ReturnRequestPageState();
}

class _ReturnRequestPageState extends State<ReturnRequestPage> {
  final Color primaryColor = const Color(0xFFB5733A);
  final Color secondaryColor = const Color(0xFFE3DCD6);
  final Color backgroundColor = const Color(0xFFFAFAFA);
  
  String? selectedReason;
  String selectedReturnType = 'refund'; // default
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _bankController = TextEditingController();
  
  XFile? _photo;
  XFile? _video;
  final ImagePicker _picker = ImagePicker();

  final List<String> reasons = [
    'Barang Cacat/Rusak',
    'Tidak Sesuai Deskripsi',
    'Bagian Tidak Lengkap',
    'Salah Kirim Barang',
  ];

  Future<void> _pickPhoto() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _photo = image;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        setState(() {
          _video = video;
        });
      }
    } catch (e) {
      debugPrint('Error picking video: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ajukan Retur',
          style: GoogleFonts.epilogue(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Product Info Card
            _buildProductInfoCard(),
            const SizedBox(height: 32),

            // 1.5 Return Type
            _buildSectionTitle('Tipe Pengembalian'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildReturnTypeCard('refund', 'Refund (Dana Kembali)', Icons.account_balance_wallet_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _buildReturnTypeCard('exchange', 'Tukar Barang', Icons.swap_horiz_rounded)),
              ],
            ),
            const SizedBox(height: 32),

            // 2. Reason for Return
            _buildSectionTitle('Alasan Pengembalian'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: reasons.map((reason) => _buildReasonChip(reason)).toList(),
            ),
            const SizedBox(height: 32),

            // 3. Detailed Description
            _buildSectionTitle('Detail Masalah'),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 32),

            if (selectedReturnType == 'refund') ...[
              _buildSectionTitle('Nomor Rekening Bank'),
              const SizedBox(height: 16),
              _buildBankField(),
              const SizedBox(height: 32),
            ],

            // 4. Upload Proof
            _buildSectionTitle('Unggah Bukti (Wajib)'),
            Text(
              'Mohon unggah foto dan video unboxing/kerusakan.',
              style: GoogleFonts.epilogue(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildUploadBox(
                  title: 'Foto Bukti',
                  file: _photo,
                  onTap: _pickPhoto,
                  icon: Icons.camera_alt_rounded,
                  isImage: true,
                )),
                const SizedBox(width: 16),
                Expanded(child: _buildUploadBox(
                  title: 'Video Bukti',
                  file: _video,
                  onTap: _pickVideo,
                  icon: Icons.videocam_rounded,
                  isImage: false,
                )),
              ],
            ),
            
            const SizedBox(height: 100), // Space for bottom button
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildReturnTypeCard(String type, String label, IconData icon) {
    final isSelected = selectedReturnType == type;
    return BounceTap(
      onTap: () => setState(() => selectedReturnType = type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : secondaryColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? primaryColor : Colors.grey, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.epilogue(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? primaryColor : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadBox({
    required String title,
    required XFile? file,
    required VoidCallback onTap,
    required IconData icon,
    required bool isImage,
  }) {
    return BounceTap(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: secondaryColor),
        ),
        child: file != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: isImage
                        ? Image.file(File(file.path), fit: BoxFit.cover)
                        : Container(
                            color: Colors.black87,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.play_circle_fill, color: Colors.white, size: 40),
                                SizedBox(height: 4),
                                Text('Video Ready', style: TextStyle(color: Colors.white, fontSize: 10)),
                              ],
                            ),
                          ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: () => setState(() {
                        if (isImage) _photo = null; else _video = null;
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: primaryColor, size: 30),
                  const SizedBox(height: 8),
                  Text(title, style: GoogleFonts.epilogue(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.epilogue(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildProductInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: secondaryColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              widget.product?.imageUrl ?? 'https://via.placeholder.com/200',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product?.name ?? 'Unknown Product',
                  style: GoogleFonts.epilogue(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Order ID: #${widget.orderId}',
                  style: GoogleFonts.epilogue(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonChip(String reason) {
    final isSelected = selectedReason == reason;
    return BounceTap(
      onTap: () {
        setState(() {
          selectedReason = reason;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : secondaryColor,
          ),
        ),
        child: Text(
          reason,
          style: GoogleFonts.epilogue(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 4,
      style: GoogleFonts.epilogue(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Ceritakan detail kerusakan...',
        hintStyle: GoogleFonts.epilogue(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: secondaryColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: primaryColor)),
        contentPadding: const EdgeInsets.all(20),
      ),
    );
  }

  Widget _buildBankField() {
    return TextFormField(
      controller: _bankController,
      style: GoogleFonts.epilogue(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Contoh: BCA 1234567890 a/n Nama',
        hintStyle: GoogleFonts.epilogue(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: secondaryColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: primaryColor)),
        contentPadding: const EdgeInsets.all(20),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        child: BounceTap(
          onTap: () async {
            if (selectedReason == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih alasan retur')));
              return;
            }
            if (_photo == null || _video == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unggah foto dan video bukti')));
              return;
            }
            if (selectedReturnType == 'refund' && _bankController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan nomor rekening')));
              return;
            }

            final provider = context.read<OrderProvider>();
            
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFB5733A))),
            );

            final success = await provider.submitReturn(
              orderId: widget.orderId,
              reason: '$selectedReason - ${_descriptionController.text}',
              returnType: selectedReturnType,
              bankAccountNumber: selectedReturnType == 'refund' ? _bankController.text : null,
              photoPath: _photo?.path,
              videoPath: _video?.path,
            );

            if (context.mounted) Navigator.pop(context); // Close loading

            if (success) {
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Berhasil'),
                    content: const Text('Pengajuan retur Anda telah terkirim.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(provider.errorMessage ?? 'Gagal mengajukan retur')),
                );
              }
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(12)),
            child: Text(
              'Kirim Pengajuan Retur',
              textAlign: TextAlign.center,
              style: GoogleFonts.epilogue(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}

class DashPainter extends CustomPainter {
  final Color color;
  DashPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 8, dashSpace = 5, startX = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    );

    final Path path = Path()..addRRect(rrect);

    for (var pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
