import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/bounce_tap.dart';
import 'return_request_page.dart';
import '../chat/chat_detail_page.dart';
import '../../core/utils/currency_formatter.dart';
import 'invoice_page.dart';

class OrderDetailsPage extends StatefulWidget {
  final OrderModel order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  static const Color primaryColor = Color(0xFFB5733A);
  static const Color secondaryColor = Color(0xFFE3DCD6);
  static const Color statusGreen = Color(0xFF4CAF50);
  static const Color statusOrange = Color(0xFFFFA000);
  static const Color statusRed = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        // Cari order terbaru dari provider
        final currentOrder = provider.orders.firstWhere(
          (o) => o.id == widget.order.id,
          orElse: () => widget.order,
        );

        final bool isReturnState = currentOrder.status == OrderStatus.returning;

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
                  final shopName = currentOrder.items.isNotEmpty 
                      ? (currentOrder.items.first.product?.shopName ?? 'Decor Official Store') 
                      : 'Decor Official Store';
                  final receiverId = currentOrder.items.isNotEmpty
                      ? (currentOrder.items.first.product?.sellerUserId ?? 0)
                      : 0;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatDetailPage(shopName: shopName, receiverId: receiverId)),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => provider.refreshOrder(currentOrder.id),
            color: primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary Header
                  _buildOrderSummaryHeader(context, currentOrder),
                  const SizedBox(height: 32),

                  // Product Items List
                  _buildProductList(currentOrder),
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
                  _buildTrackingTimeline(isReturnState, currentOrder),

                  const SizedBox(height: 40),

                  // Payment Summary
                  _buildPaymentSummary(currentOrder),
                  const SizedBox(height: 32),

                  // ADD CHAT SELLER BUTTON HERE TOO
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final shopName = currentOrder.items.isNotEmpty 
                            ? (currentOrder.items.first.product?.shopName ?? 'Decor Official Store') 
                            : 'Decor Official Store';
                        final receiverId = currentOrder.items.isNotEmpty
                            ? (currentOrder.items.first.product?.sellerUserId ?? 0)
                            : 0;
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChatDetailPage(shopName: shopName, receiverId: receiverId)),
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
          ),
          bottomNavigationBar: _buildBottomActionBar(context, currentOrder),
        );
      },
    );
  }

  Widget _buildOrderSummaryHeader(BuildContext context, OrderModel order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order ID: #${order.id}',
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
        _buildStatusBadge(order),
      ],
    );
  }

  Widget _buildStatusBadge(OrderModel order) {
    Color bgColor;
    String label;

    switch (order.status) {
      case OrderStatus.processing:
        bgColor = primaryColor;
        label = 'Processing';
        break;
      case OrderStatus.shipped:
        bgColor = statusOrange;
        label = 'On the way';
        break;
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
        label = 'PENDING';
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

  Widget _buildProductList(OrderModel order) {
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
                  item.product?.imageUrl ?? 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=200&q=80',
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
                      item.product?.name ?? 'Unknown Product',
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
                (item.price * item.quantity).toIDR(),
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

  Widget _buildTrackingTimeline(bool isReturn, OrderModel order) {
    if (isReturn) {
      return Column(
        children: [
          _buildTimelineStep('Return Requested', 'Submitted on ${DateFormat('MMM dd').format(order.orderDate)}', isCompleted: true),
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
              isCompleted: order.status != OrderStatus.processing && order.status != OrderStatus.cancelled, 
              isCurrent: order.status == OrderStatus.processing),
          _buildTimelineStep('Shipped', 'Your order is on the way', 
              isCompleted: order.status == OrderStatus.delivered,
              isCurrent: order.status == OrderStatus.shipped,
              isUpcoming: order.status == OrderStatus.processing),
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

  Widget _buildPaymentSummary(OrderModel order) {
    // Calculate original subtotal from items
    final double itemsSubtotal = order.items.fold(0, (sum, item) => sum + (item.price * item.quantity));
    final double shipping = 300000.0; // Mock breakdown based on current UI
    final double taxes = 75000.0;

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
        _buildPriceRow('Subtotal', itemsSubtotal.toIDR()),
        if (order.discountAmount > 0) ...[
          const SizedBox(height: 12),
          _buildPriceRow('Voucher Discount', '- ${order.discountAmount.toIDR()}', valueColor: Colors.green),
        ],
        const SizedBox(height: 12),
        _buildPriceRow('Shipping', shipping.toIDR()),
        const SizedBox(height: 12),
        _buildPriceRow('Taxes', taxes.toIDR()),
        const Divider(height: 32),
        _buildPriceRow('Grand Total', order.totalAmount.toIDR(), isBold: true),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context, // Using context is safe here because it's a stateless build section
                MaterialPageRoute(
                  builder: (context) => InvoicePage(order: order),
                ),
              );
            },
            icon: const Icon(Icons.receipt_long, size: 18),
            label: const Text('VIEW INVOICE'),
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              side: const BorderSide(color: primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false, Color? valueColor}) {
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
            color: valueColor ?? (isBold ? primaryColor : Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(BuildContext context, OrderModel order) {
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
