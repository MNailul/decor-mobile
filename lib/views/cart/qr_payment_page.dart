import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../profile/orders_page.dart';

class QrPaymentPage extends StatefulWidget {
  final double amount;

  const QrPaymentPage({super.key, required this.amount});

  @override
  State<QrPaymentPage> createState() => _QrPaymentPageState();
}

class _QrPaymentPageState extends State<QrPaymentPage> {
  static const Color primaryColor = Color(0xFFB5733A);
  static const Color secondaryColor = Color(0xFFE3DCD6);
  static const Color textColor = Color(0xFF1E1E1E);
  static const Color lightTextColor = Color(0xFF757575);

  late Timer _timer;
  int _start = 900; // 15 minutes

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
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
          'QR PAYMENT',
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
            Text(
              'Complete your payment in',
              style: GoogleFonts.epilogue(
                color: lightTextColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formatTime(_start),
              style: GoogleFonts.epilogue(
                color: primaryColor,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 40),
            
            // QR Code Container
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: secondaryColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Image.network(
                    'https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=DecorAppDummyPayment123',
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Scan with any QRIS supported app',
                    style: GoogleFonts.epilogue(
                      color: lightTextColor,
                      fontSize: 13,
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
                        '\$${widget.amount.toStringAsFixed(2)}',
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
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  final cartProvider = context.read<CartProvider>();
                  final orderProvider = context.read<OrderProvider>();

                  // 1. Create order items from selected cart items
                  final orderItems = cartProvider.selectedItems.map((item) {
                    return OrderItem(product: item.product, quantity: item.quantity);
                  }).toList();

                  // 2. Create the order
                  final newOrder = OrderModel(
                    id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
                    items: orderItems,
                    totalAmount: widget.amount,
                    orderDate: DateTime.now(),
                    status: OrderStatus.ordered,
                  );

                  // 3. Save the order
                  orderProvider.addOrder(newOrder);

                  // 4. Show success sheet
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => SuccessBottomSheet(amount: widget.amount),
                  );
                },
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
          ],
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
                  text: '\$${amount.toStringAsFixed(2)}',
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
