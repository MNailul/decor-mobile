import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../models/consultation_model.dart';
import '../../providers/consultation_provider.dart';
import '../profile/consultation_history_page.dart';

class ConsultationPaymentPage extends StatefulWidget {
  final Map<String, dynamic> designer;
  final String consultationType;
  final DateTime date;
  final String time;
  final double totalPrice;
  final String? projectBrief;

  const ConsultationPaymentPage({
    super.key,
    required this.designer,
    required this.consultationType,
    required this.date,
    required this.time,
    required this.totalPrice,
    this.projectBrief,
  });

  @override
  State<ConsultationPaymentPage> createState() => _ConsultationPaymentPageState();
}

class _ConsultationPaymentPageState extends State<ConsultationPaymentPage> {
  static const Color primaryColor = Color(0xFFB5733A);
  static const Color secondaryColor = Color(0xFFE3DCD6);
  static const Color textColor = Color(0xFF1E1E1E);
  static const Color lightTextColor = Color(0xFF757575);
  
  bool isFullPayment = true;
  String selectedPaymentMethod = 'QR Code';
  int _timerStart = 900; // 15 minutes
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerStart == 0) {
        timer.cancel();
      } else {
        setState(() => _timerStart--);
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  double get amountToPay => isFullPayment ? widget.totalPrice : widget.totalPrice * 0.3;

  String formatCurrency(double amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1).replaceAll('.0', '')}jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toInt()}k';
    }
    return 'Rp ${amount.toInt()}';
  }

  @override
  Widget build(BuildContext context) {
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
          'CHECKOUT',
          style: GoogleFonts.epilogue(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Card (similar to checkout address/shipping cards)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: secondaryColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CONSULTATION SUMMARY',
                      style: GoogleFonts.epilogue(
                        color: lightTextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.designer['image'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.designer['name'],
                                style: GoogleFonts.epilogue(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                '${widget.consultationType} Consultation',
                                style: GoogleFonts.epilogue(
                                  color: lightTextColor,
                                  fontSize: 13,
                                ),
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
                    _buildSummaryRow('Date', '${widget.date.day}/${widget.date.month}/${widget.date.year}'),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Time', widget.time),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Total Price', formatCurrency(widget.totalPrice), isBold: true),
                  ],
                ),
              ),
            ),

            // Payment Options (DP vs Full)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PAYMENT OPTION',
                    style: GoogleFonts.epilogue(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOptionCard(
                          title: 'Full Payment',
                          subtitle: formatCurrency(widget.totalPrice),
                          isSelected: isFullPayment,
                          onTap: () => setState(() => isFullPayment = true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildOptionCard(
                          title: 'Down Payment (30%)',
                          subtitle: formatCurrency(widget.totalPrice * 0.3),
                          isSelected: !isFullPayment,
                          onTap: () => setState(() => isFullPayment = false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Payment Method Selector
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PAYMENT METHOD',
                    style: GoogleFonts.epilogue(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentMethodCard(),
                ],
              ),
            ),

            if (selectedPaymentMethod == 'QR Code') ...[
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Complete your payment in',
                      style: GoogleFonts.epilogue(
                        color: lightTextColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(_timerStart),
                      style: GoogleFonts.epilogue(
                        color: primaryColor,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
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
                          Image.network(
                            'https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=DecorAppConsultationPayment',
                            width: 180,
                            height: 180,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Scan with any QRIS supported app',
                            style: GoogleFonts.epilogue(
                              color: lightTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _processPayment,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: const BorderSide(color: primaryColor, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'I HAVE PAID',
                            style: GoogleFonts.epilogue(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Virtual Account placeholder
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: secondaryColor),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Virtual Account Number',
                        style: GoogleFonts.epilogue(
                          color: lightTextColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '8839 0812 3456 7890',
                        style: GoogleFonts.epilogue(
                          color: textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bank Mandiri • Decor App',
                        style: GoogleFonts.epilogue(
                          color: lightTextColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomSheet: selectedPaymentMethod == 'Virtual Account' ? Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'TOTAL PAYMENT',
                    style: GoogleFonts.epilogue(
                      color: lightTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatCurrency(amountToPay),
                    style: GoogleFonts.epilogue(
                      color: primaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'BAYAR SEKARANG',
                  style: GoogleFonts.epilogue(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ) : null,
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.epilogue(
            color: lightTextColor,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.epilogue(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: 14,
            color: isBold ? primaryColor : textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.05) : Colors.white,
          border: Border.all(
            color: isSelected ? primaryColor : secondaryColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.epilogue(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isSelected ? primaryColor : lightTextColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.epilogue(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isSelected ? primaryColor : textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    bool isQr = selectedPaymentMethod == 'QR Code';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: secondaryColor),
      ),
      child: Row(
        children: [
          Icon(
            isQr ? Icons.qr_code_scanner : Icons.account_balance,
            color: textColor,
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedPaymentMethod,
                  style: GoogleFonts.epilogue(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isQr ? 'Scan QR with any app' : 'Virtual Account Number',
                  style: GoogleFonts.epilogue(
                    color: lightTextColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => _buildPaymentSelector(),
              );
            },
            child: Text(
              'CHANGE',
              style: GoogleFonts.epilogue(
                color: primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSelector() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Payment Method',
            style: GoogleFonts.epilogue(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.qr_code_scanner, color: textColor),
            title: Text(
              'QR Code',
              style: GoogleFonts.epilogue(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            trailing: selectedPaymentMethod == 'QR Code'
                ? const Icon(Icons.check_circle, color: primaryColor)
                : null,
            onTap: () {
              setState(() => selectedPaymentMethod = 'QR Code');
              Navigator.pop(context);
            },
          ),
          const Divider(color: secondaryColor),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.account_balance, color: textColor),
            title: Text(
              'Virtual Account',
              style: GoogleFonts.epilogue(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            trailing: selectedPaymentMethod == 'Virtual Account'
                ? const Icon(Icons.check_circle, color: primaryColor)
                : null,
            onTap: () {
              setState(() => selectedPaymentMethod = 'Virtual Account');
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _processPayment() {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: primaryColor)),
    );

    // Simulate payment delay
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context); // Pop loading

      // Save consultation
      final consultation = ConsultationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        designerName: widget.designer['name'],
        designerImage: widget.designer['image'],
        consultationType: widget.consultationType,
        date: widget.date,
        time: widget.time,
        totalPrice: widget.totalPrice,
        paidAmount: amountToPay,
        isFullPayment: isFullPayment,
        status: ConsultationStatus.scheduled,
        projectBrief: widget.projectBrief,
      );

      Provider.of<ConsultationProvider>(context, listen: false).addConsultation(consultation);

      // Show success sheet (consistent with checkout)
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => SuccessBottomSheet(amount: amountToPay),
      );
    });
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
            'Booking Berhasil!',
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
                const TextSpan(text: 'Konsultasi Anda telah dijadwalkan.\nTotal Terbayar: '),
                TextSpan(
                  text: 'Rp ${amount >= 1000 ? (amount / 1000).toInt() : amount.toInt()}k',
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
                Navigator.pop(context); // Close sheet
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ConsultationHistoryPage()),
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
                'Lihat Status Konsultasi',
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
                'Kembali ke Beranda',
                style: GoogleFonts.epilogue(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
