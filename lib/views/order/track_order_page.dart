import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/order_model.dart';
import 'package:intl/intl.dart';

class TrackOrderPage extends StatelessWidget {
  final OrderModel order;

  const TrackOrderPage({super.key, required this.order});

  static const Color primaryColor = Color(0xFFB5733A);
  static const Color secondaryColor = Color(0xFFE3DCD6);
  static const Color textColor = Color(0xFF1E1E1E);
  static const Color lightTextColor = Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM dd, yyyy').format(order.orderDate);

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
            fontSize: 16,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
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
                      order.id,
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
            _buildTrackingTimeline(),

            const SizedBox(height: 40),

            // Courier Info Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&q=80'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Michael Anderson',
                          style: GoogleFonts.epilogue(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: textColor,
                          ),
                        ),
                        Text(
                          'Your Dedicated Courier',
                          style: GoogleFonts.epilogue(
                            fontSize: 12,
                            color: lightTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.phone_outlined, color: primaryColor, size: 20),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

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
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item.product.imagePath,
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
                          item.product.name,
                          style: GoogleFonts.epilogue(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: textColor,
                          ),
                        ),
                        Text(
                          '${item.quantity} x \$${item.product.price.toStringAsFixed(2)}',
                          style: GoogleFonts.epilogue(
                            fontSize: 12,
                            color: lightTextColor,
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
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingTimeline() {
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
          isCurrent: order.status == OrderStatus.ordered,
          isCompleted: order.status != OrderStatus.ordered,
        ),
        _buildTimelineStep(
          'Shipped',
          'Your order is on the way.',
          isUpcoming: order.status == OrderStatus.ordered || order.status == OrderStatus.processing,
          isCurrent: order.status == OrderStatus.shipped,
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
