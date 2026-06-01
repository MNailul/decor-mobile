import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../core/utils/currency_formatter.dart';
import 'package:intl/intl.dart';

class ReturnDetailPage extends StatelessWidget {
  final OrderModel order;

  const ReturnDetailPage({super.key, required this.order});

  static const Color primaryColor = Color(0xFFB5733A);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFE57373);
  static const Color warningColor = Color(0xFFFFB74D);
  static const Color textColor = Color(0xFF1E1E1E);
  static const Color lightTextColor = Color(0xFF757575);

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
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'RETURN DETAILS',
          style: GoogleFonts.epilogue(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          // Sync with latest data if possible
          final currentOrder = provider.orders.firstWhere(
            (o) => o.id == order.id,
            orElse: () => order,
          );

          return RefreshIndicator(
            onRefresh: () => provider.refreshOrder(currentOrder.id),
            color: primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Status Header Card
                  _buildStatusHeader(currentOrder),
                  const SizedBox(height: 32),

                  // 2. Timeline
                  _buildSectionTitle('ACTIVITY LOG'),
                  const SizedBox(height: 20),
                  _buildReturnTimeline(currentOrder),
                  const SizedBox(height: 32),

                  // 3. Product Info
                  _buildSectionTitle('ITEM RETURNED'),
                  const SizedBox(height: 16),
                  _buildProductCard(currentOrder),
                  const SizedBox(height: 32),

                  // 4. Reason & Proof
                  _buildSectionTitle('REASON & PROOF'),
                  const SizedBox(height: 16),
                  _buildReasonSection(currentOrder),
                  
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 32),

                  // 5. Help Section
                  _buildHelpSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.epilogue(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: lightTextColor,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildStatusHeader(OrderModel order) {
    final status = order.returnStatus?.toLowerCase() ?? 'pending';
    Color color;
    String description;
    IconData icon;

    switch (status) {
      case 'approved':
        color = successColor;
        description = 'Your return request has been approved by the seller.';
        icon = Icons.check_circle_outline;
        break;
      case 'rejected':
        color = errorColor;
        description = 'Sorry, your return request was rejected. Please contact support for more info.';
        icon = Icons.cancel_outlined;
        break;
      default:
        color = warningColor;
        description = 'The seller is currently reviewing your return request.';
        icon = Icons.access_time;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 48),
          const SizedBox(height: 16),
          Text(
            'RETURN ${status.toUpperCase()}',
            style: GoogleFonts.epilogue(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.epilogue(
              fontSize: 13,
              color: textColor.withOpacity(0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnTimeline(OrderModel order) {
    final status = order.returnStatus?.toLowerCase() ?? 'pending';
    
    return Column(
      children: [
        _buildTimelineStep(
          'Request Submitted',
          'Waiting for seller confirmation',
          DateFormat('MMM dd, HH:mm').format(order.orderDate.add(const Duration(hours: 1))), // Mock time
          isCompleted: true,
        ),
        _buildTimelineStep(
          status == 'rejected' ? 'Request Rejected' : 'Request Approved',
          status == 'rejected' ? 'Reason: Not meeting requirements' : 'Seller has approved your return',
          status != 'pending' ? 'May 10, 09:45' : '-', // Mock time
          isCompleted: status != 'pending',
          isError: status == 'rejected',
          isLast: status != 'approved',
        ),
        if (status == 'approved')
          _buildTimelineStep(
            'Refund Processed',
            'Funds will be returned to your original method',
            'Pending',
            isCurrent: true,
            isLast: true,
          ),
      ],
    );
  }

  Widget _buildTimelineStep(String title, String subtitle, String time, {
    bool isCompleted = false, 
    bool isCurrent = false, 
    bool isError = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isError ? errorColor : (isCompleted ? primaryColor : (isCurrent ? Colors.white : Colors.grey.shade300)),
                  border: isCurrent ? Border.all(color: primaryColor, width: 3) : null,
                ),
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.epilogue(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isCompleted || isCurrent ? textColor : lightTextColor,
                      ),
                    ),
                    Text(
                      time,
                      style: GoogleFonts.epilogue(
                        fontSize: 10,
                        color: lightTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.epilogue(
                    fontSize: 12,
                    color: lightTextColor,
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

  Widget _buildProductCard(OrderModel order) {
    final item = order.items.first;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.product?.imageUrl ?? 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=200&q=80',
              width: 56,
              height: 56,
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
                  ),
                ),
                Text(
                  '${item.quantity} Unit • ${item.price.toIDR()}',
                  style: GoogleFonts.epilogue(
                    fontSize: 12,
                    color: lightTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonSection(OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Text(
            order.returnReason ?? 'No reason provided.',
            style: GoogleFonts.epilogue(
              fontSize: 13,
              color: textColor.withOpacity(0.8),
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Dummy Proof Grid
        Row(
          children: [
            _buildProofThumbnail('https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=200&q=80'),
            const SizedBox(width: 12),
            _buildProofThumbnail('https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=200&q=80'),
          ],
        ),
      ],
    );
  }

  Widget _buildProofThumbnail(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildHelpSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.support_agent, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need Help?',
                  style: GoogleFonts.epilogue(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Talk to our agent if you have issues with your return.',
                  style: GoogleFonts.epilogue(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        ],
      ),
    );
  }
}
