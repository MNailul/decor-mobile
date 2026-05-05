import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/bounce_tap.dart';
import 'return_request_page.dart';
import '../chat/chat_detail_page.dart';

class OrderDetailsPage extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsPage({super.key, required this.order});

  static const Color primaryColor = Color(0xFFB5733A);
  static const Color secondaryColor = Color(0xFFE3DCD6);
  static const Color statusGreen = Color(0xFF4CAF50);
  static const Color statusOrange = Color(0xFFFFA000);
  static const Color statusRed = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    final bool isReturnState = order.status == OrderStatus.returning;
    final dateStr = DateFormat('MMM dd, yyyy').format(order.orderDate);

    return Scaffold(
      backgroundColor: Colors.white,
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
          'Order Details',
          style: GoogleFonts.epilogue(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: primaryColor),
            onPressed: () {
              final shopName = order.items.isNotEmpty 
                  ? order.items.first.product.shopName 
                  : 'Decor Official Store';
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatDetailPage(shopName: shopName)),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Header
            _buildOrderSummaryHeader(context),
            const SizedBox(height: 32),

            // Product Items List
            _buildProductList(),
            const SizedBox(height: 40),

            // Dynamic Vertical Tracking Timeline
            Text(
              isReturnState ? 'RETURN STATUS' : 'DELIVERY STATUS',
              style: GoogleFonts.epilogue(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            _buildTrackingTimeline(isReturnState),

            const SizedBox(height: 40),

            // Payment Summary
            _buildPaymentSummary(),
            const SizedBox(height: 32),

            // ADD CHAT SELLER BUTTON HERE TOO
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final shopName = order.items.isNotEmpty 
                      ? order.items.first.product.shopName 
                      : 'Decor Official Store';
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatDetailPage(shopName: shopName)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: primaryColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: primaryColor, width: 1.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chat_bubble_outline, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'NEED HELP? CHAT SELLER',
                      style: GoogleFonts.epilogue(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(context),
    );
  }

  Widget _buildOrderSummaryHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order ID: ${order.id}',
                style: GoogleFonts.epilogue(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Order Date: ${DateFormat('MMM dd, yyyy').format(order.orderDate)}',
                style: GoogleFonts.epilogue(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    String label;

    switch (order.status) {
      case OrderStatus.delivered:
        bgColor = statusGreen;
        label = 'Delivered';
        break;
      case OrderStatus.returning:
        bgColor = statusOrange;
        label = 'Return Processing';
        break;
      case OrderStatus.cancelled:
        bgColor = statusRed;
        label = 'Cancelled';
        break;
      default:
        bgColor = primaryColor;
        label = order.status.name.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.epilogue(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: secondaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: order.items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.product.imagePath,
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
                      item.product.name,
                      style: GoogleFonts.epilogue(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Qty: ${item.quantity}',
                      style: GoogleFonts.epilogue(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                style: GoogleFonts.epilogue(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildTrackingTimeline(bool isReturn) {
    if (isReturn) {
      return Column(
        children: [
          _buildTimelineStep('Return Requested', 'Submitted on ${DateFormat('MMM dd').format(DateTime.now())}', isCompleted: true),
          _buildTimelineStep('Awaiting Seller Approval', 'Seller is checking item condition', isCurrent: true),
          _buildTimelineStep('Item Shipped Back', 'Pending approval', isUpcoming: true),
          _buildTimelineStep('Refund Issued', 'Final step', isUpcoming: true, isLast: true),
        ],
      );
    } else {
      return Column(
        children: [
          _buildTimelineStep('Ordered', 'We have received your order', isCompleted: true),
          _buildTimelineStep('Processing', 'Your items are being prepared', 
              isCompleted: order.status != OrderStatus.ordered, 
              isCurrent: order.status == OrderStatus.ordered),
          _buildTimelineStep('Shipped', 'Your order is on the way', 
              isCompleted: order.status == OrderStatus.delivered,
              isCurrent: order.status == OrderStatus.shipped,
              isUpcoming: order.status == OrderStatus.ordered || order.status == OrderStatus.processing),
          _buildTimelineStep('Delivered', 'Order reached its destination', 
              isCurrent: order.status == OrderStatus.delivered,
              isUpcoming: order.status != OrderStatus.delivered,
              isLast: true),
        ],
      );
    }
  }

  Widget _buildTimelineStep(String title, String subtitle, {bool isCompleted = false, bool isCurrent = false, bool isUpcoming = false, bool isLast = false}) {
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
                  color: isCompleted ? primaryColor : (isCurrent ? Colors.white : Colors.grey.shade200),
                  border: isCurrent ? Border.all(color: primaryColor, width: 5) : (isCompleted ? null : Border.all(color: Colors.grey.shade300, width: 2)),
                ),
                child: isCompleted ? const Icon(Icons.check, color: Colors.white, size: 12) : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? primaryColor : Colors.grey.shade200,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.epilogue(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isUpcoming ? Colors.grey.shade400 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.epilogue(
                    fontSize: 12,
                    color: isCurrent ? primaryColor : (isUpcoming ? Colors.grey.shade400 : Colors.grey.shade600),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    final subtotal = order.totalAmount - 25.0; // Mock breakdown
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PAYMENT SUMMARY',
          style: GoogleFonts.epilogue(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade500,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        _buildPriceRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
        const SizedBox(height: 12),
        _buildPriceRow('Shipping', '\$20.00'),
        const SizedBox(height: 12),
        _buildPriceRow('Taxes', '\$5.00'),
        const Divider(height: 32),
        _buildPriceRow('Grand Total', '\$${order.totalAmount.toStringAsFixed(2)}', isBold: true),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.epilogue(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? Colors.black87 : Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.epilogue(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? primaryColor : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    // Check if within 7-day window
    final bool canReturn = order.status == OrderStatus.delivered && 
        DateTime.now().difference(order.orderDate).inDays <= 7;
    
    final bool isReturning = order.status == OrderStatus.returning;

    if (!canReturn && !isReturning) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: isReturning 
          ? SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // View return details logic
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Lihat Detail Pengajuan Retur',
                  style: GoogleFonts.epilogue(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          : BounceTap(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReturnRequestPage(
                      product: order.items.first.product,
                      orderId: order.id,
                    ),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Ajukan Retur',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.epilogue(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
