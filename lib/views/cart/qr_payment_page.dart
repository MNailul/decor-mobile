import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../profile/orders_page.dart';
import '../../core/utils/currency_formatter.dart';


class BankTransferPage extends StatefulWidget {
  final double amount;
  final String orderId;

  const BankTransferPage({super.key, required this.amount, required this.orderId});

  @override
  State<BankTransferPage> createState() => _BankTransferPageState();
}

class _BankTransferPageState extends State<BankTransferPage> {
  static const Color primaryColor = Color(0xFFB5733A);
  static const Color secondaryColor = Color(0xFFE3DCD6);
  static const Color textColor = Color(0xFF1E1E1E);
  static const Color lightTextColor = Color(0xFF757575);

  XFile? _proofImage;
  final ImagePicker _picker = ImagePicker();
  bool _isChecking = false;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _proofImage = image;
      });
    }
  }

  Future<void> _checkPaymentStatus() async {
    setState(() => _isChecking = true);
    final orderProvider = context.read<OrderProvider>();
    final updatedOrder = await orderProvider.refreshOrder(widget.orderId);
    setState(() => _isChecking = false);

    if (updatedOrder != null && updatedOrder.status == OrderStatus.processing && mounted) {
      // Show success sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => SuccessBottomSheet(amount: widget.amount),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembayaran belum dikonfirmasi oleh admin.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'BANK TRANSFER',
          style: GoogleFonts.epilogue(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            
            // VA Container
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: secondaryColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'VIRTUAL ACCOUNT',
                    style: GoogleFonts.epilogue(
                      color: lightTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '8801 0812 3456 7890',
                        style: GoogleFonts.epilogue(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.copy, size: 18, color: primaryColor),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Bank Central Asia (BCA)',
                    style: GoogleFonts.epilogue(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Order Summary
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ORDER SUMMARY',
                style: GoogleFonts.epilogue(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: secondaryColor),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Payment',
                        style: GoogleFonts.epilogue(
                          color: lightTextColor,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        widget.amount.toIDR(),
                        style: GoogleFonts.epilogue(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: secondaryColor, thickness: 1, height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order ID',
                        style: GoogleFonts.epilogue(
                          color: lightTextColor,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '#DEC-90210',
                        style: GoogleFonts.epilogue(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            // Payment Proof Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: secondaryColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: secondaryColor),
              ),
              child: Column(
                children: [
                  Text(
                    'UPLOAD BUKTI PEMBAYARAN',
                    style: GoogleFonts.epilogue(
                      color: lightTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_proofImage != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_proofImage!.path),
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        PositionAtCorner(
                          onTap: () => setState(() => _proofImage = null),
                        ),
                      ],
                    )
                  else
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: secondaryColor, style: BorderStyle.solid),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_a_photo_outlined, color: primaryColor, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              'Pilih Foto dari Galeri',
                              style: GoogleFonts.epilogue(color: lightTextColor, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            Consumer<OrderProvider>(
              builder: (context, orderProvider, child) {
                final order = orderProvider.orders.any((o) => o.id == widget.orderId) 
                    ? orderProvider.orders.firstWhere((o) => o.id == widget.orderId)
                    : null;
                
                bool isAwaiting = order?.status == OrderStatus.awaiting_verification;
                
                return Column(
                  children: [
                    if (isAwaiting) ...[
                      Text(
                        'Menunggu verifikasi admin...',
                        style: GoogleFonts.epilogue(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isAwaiting 
                          ? (_isChecking ? null : _checkPaymentStatus)
                          : () async {
                              if (_proofImage == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Silakan pilih bukti pembayaran terlebih dahulu.')),
                                );
                                return;
                              }

                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(child: CircularProgressIndicator(color: primaryColor)),
                              );

                              final success = await orderProvider.payOrder(widget.orderId, _proofImage!.path);

                              if (mounted) Navigator.pop(context);

                              if (success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Bukti pembayaran berhasil diupload!')),
                                );
                              } else if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(orderProvider.errorMessage ?? 'Gagal upload bukti.')),
                                );
                              }
                            },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isChecking 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              isAwaiting ? 'CEK STATUS PEMBAYARAN' : 'SAYA SUDAH BAYAR',
                              style: GoogleFonts.epilogue(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PositionAtCorner extends StatelessWidget {
  final VoidCallback onTap;
  const PositionAtCorner({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 8,
      top: 8,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close, color: Colors.white, size: 16),
        ),
      ),
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
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          // Lottie Success Animation
          SizedBox(
            width: 120,
            height: 120,
            child: Lottie.asset(
              'assets/animations/success.json',
              repeat: false,
              animate: true,
            ),
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            'Pembayaran Berhasil!',
            style: GoogleFonts.epilogue(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Subtitle
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.epilogue(
                color: Colors.grey.shade600,
                fontSize: 14,
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'Terima kasih atas pesanan Anda.\nTotal: '),
                TextSpan(
                  text: amount.toIDR(),
                  style: GoogleFonts.epilogue(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // Action Buttons
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                // Clear selected items from cart first
                context.read<CartProvider>().clearSelectedItems();
                
                Navigator.pop(context); // Close sheet
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const OrdersPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Lihat Status Pesanan',
                style: GoogleFonts.epilogue(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                // Clear selected items from cart
                context.read<CartProvider>().clearSelectedItems();
                Navigator.pop(context); // Close sheet
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: primaryColor),
                foregroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Kembali Berbelanja',
                style: GoogleFonts.epilogue(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24), // Extra bottom padding
        ],
      ),
    );
  }
}
