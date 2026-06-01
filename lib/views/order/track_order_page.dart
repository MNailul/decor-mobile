import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../chat/chat_detail_page.dart';
import 'package:intl/intl.dart';
import '../../core/utils/currency_formatter.dart';
import 'return_request_page.dart';

class TrackOrderPage extends StatefulWidget {
  final OrderModel order;

  const TrackOrderPage({super.key, required this.order});

  @override
  State<TrackOrderPage> createState() => _TrackOrderPageState();
}

class _TrackOrderPageState extends State<TrackOrderPage> {
  static const Color primaryColor = Color(0xFFB5733A);
  static const Color textColor = Color(0xFF1E1E1E);
  static const Color lightTextColor = Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        // Cari order terbaru dari provider berdasarkan ID
        final currentOrder = provider.orders.firstWhere(
          (o) => o.id == widget.order.id,
          orElse: () => widget.order,
        );

        final dateStr = DateFormat('MMM dd, yyyy').format(currentOrder.orderDate);
        final shopName = currentOrder.items.isNotEmpty 
            ? (currentOrder.items.first.product?.shopName ?? 'Decor Official Store') 
            : 'Decor Official Store';

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
              'TRACK ORDER',
              style: GoogleFonts.epilogue(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 1.5,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline, color: primaryColor),
                onPressed: () {
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
                  // Order ID & Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ORDER ID',
                            style: GoogleFonts.epilogue(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: lightTextColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '#${currentOrder.id}',
                            style: GoogleFonts.epilogue(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'ORDER DATE',
                            style: GoogleFonts.epilogue(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: lightTextColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateStr,
                            style: GoogleFonts.epilogue(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Tracking Visualizer
                  Text(
                    'DELIVERY STATUS',
                    style: GoogleFonts.epilogue(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: lightTextColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTrackingTimeline(currentOrder),

                  const SizedBox(height: 40),

                  // Order Items
                  Text(
                    'ITEMS',
                    style: GoogleFonts.epilogue(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: lightTextColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...currentOrder.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            item.product?.imageUrl ?? 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=200&q=80',
                            width: 64,
                            height: 64,
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
                                  color: textColor,
                                ),
                              ),
                              Text(
                                '${item.quantity} x ${item.price.toIDR()}',
                                style: GoogleFonts.epilogue(
                                  fontSize: 12,
                                  color: lightTextColor,
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
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  )),

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Shipping Address Summary
                  Text(
                    'SHIPPING ADDRESS',
                    style: GoogleFonts.epilogue(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: lightTextColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'John Doe\n123 Luxury Avenue, Suite 405\nBeverly Hills, CA 90210\n+1 (555) 012-3456',
                    style: GoogleFonts.epilogue(
                      fontSize: 14,
                      color: textColor,
                      height: 1.6,
                    ),
                  ),
                  
                  const SizedBox(height: 40),

                  // RETURN ACTION OR STATUS
                  if (currentOrder.status == OrderStatus.delivered) ...[
                    const SizedBox(height: 16),
                    if (currentOrder.returnStatus == null && !currentOrder.hasReviewed)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReturnRequestPage(
                                  product: currentOrder.items.first.product,
                                  orderId: currentOrder.id,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'RETURN REQUEST',
                            style: GoogleFonts.epilogue(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: currentOrder.returnStatus == 'approved' 
                              ? Colors.green.withOpacity(0.1) 
                              : (currentOrder.returnStatus == 'rejected' ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'RETURN ${currentOrder.returnStatus!.toUpperCase()}',
                              style: GoogleFonts.epilogue(
                                fontWeight: FontWeight.bold,
                                color: currentOrder.returnStatus == 'approved' 
                                    ? Colors.green 
                                    : (currentOrder.returnStatus == 'rejected' ? Colors.red : Colors.orange),
                              ),
                            ),
                            if (currentOrder.returnReason != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                currentOrder.returnReason!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.epilogue(fontSize: 12, color: Colors.grey.shade700),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],

                  const SizedBox(height: 16),

                  // BIG ACTION BUTTON AT BOTTOM
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
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
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrackingTimeline(OrderModel order) {
    return Column(
      children: [
        _buildTimelineStep(
          'Ordered',
          'We have received your order.',
          isCompleted: true,
        ),
        _buildTimelineStep(
          'Processing',
          'Your items are being prepared.',
          isCurrent: order.status == OrderStatus.processing,
          isCompleted: order.status != OrderStatus.processing && order.status != OrderStatus.cancelled,
        ),
        _buildTimelineStep(
          'Shipped',
          'Your order is on the way.',
          isUpcoming: order.status == OrderStatus.processing,
          isCurrent: order.status == OrderStatus.shipped,
          isCompleted: order.status == OrderStatus.delivered,
        ),
        _buildTimelineStep(
          'Delivered',
          'Order reached its destination.',
          isUpcoming: order.status != OrderStatus.delivered,
          isCurrent: order.status == OrderStatus.delivered,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildTimelineStep(
    String title,
    String subtitle, {
    bool isCompleted = false,
    bool isCurrent = false,
    bool isUpcoming = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? primaryColor : (isCurrent ? Colors.white : Colors.grey.shade200),
                  border: isCurrent
                      ? Border.all(color: primaryColor, width: 6)
                      : (isCompleted ? null : Border.all(color: Colors.grey.shade300, width: 2)),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? primaryColor : Colors.grey.shade200,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.epilogue(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isUpcoming ? Colors.grey.shade400 : textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.epilogue(
                    fontSize: 13,
                    color: isCurrent ? primaryColor : (isUpcoming ? Colors.grey.shade400 : lightTextColor),
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
}
