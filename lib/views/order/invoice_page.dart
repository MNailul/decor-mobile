import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/order_model.dart';
import 'package:intl/intl.dart';

class InvoicePage extends StatelessWidget {
  final OrderModel order;

  const InvoicePage({super.key, required this.order});

  static const Color primaryColor = Color(0xFFB5733A);
  static const Color textColor = Color(0xFF1E1E1E);
  static const Color lightTextColor = Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM dd, yyyy').format(order.orderDate);
    final subtotal = order.items.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
    const shipping = 15.0;
    const taxes = 24.40;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'INVOICE',
          style: GoogleFonts.epilogue(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                  // Header section
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.chair, color: Colors.white, size: 32),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'DECOR',
                          style: GoogleFonts.epilogue(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Receipt for Order ${order.id}',
                          style: GoogleFonts.epilogue(
                            color: lightTextColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Order Details section
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoColumn('ORDER DATE', dateStr),
                            _buildInfoColumn('STATUS', order.status.name.toUpperCase()),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _buildInfoColumn('BILL TO', 'John Doe\n123 Luxury Avenue, Suite 405\nBeverly Hills, CA 90210'),
                        const SizedBox(height: 40),
                        
                        // Itemized List
                        Text(
                          'ITEMS',
                          style: GoogleFonts.epilogue(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: lightTextColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...order.items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.quantity} x ${item.product.name}',
                                  style: GoogleFonts.epilogue(fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                              ),
                              Text(
                                '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                                style: GoogleFonts.epilogue(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),

                        // Totals section
                        _buildTotalRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
                        const SizedBox(height: 12),
                        _buildTotalRow('Shipping', '\$${shipping.toStringAsFixed(2)}'),
                        const SizedBox(height: 12),
                        _buildTotalRow('Taxes', '\$${taxes.toStringAsFixed(2)}'),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Payment',
                              style: GoogleFonts.epilogue(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '\$${order.totalAmount.toStringAsFixed(2)}',
                              style: GoogleFonts.epilogue(
                                fontSize: 20, 
                                fontWeight: FontWeight.w900,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Footer section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                    ),
                    child: Center(
                      child: Text(
                        'Thank you for your trust in DECOR.',
                        style: GoogleFonts.epilogue(
                          color: lightTextColor,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // Print/Download Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download, size: 20),
                label: const Text('DOWNLOAD INVOICE'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.epilogue(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: lightTextColor,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.epilogue(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.epilogue(fontSize: 14, color: lightTextColor),
        ),
        Text(
          amount,
          style: GoogleFonts.epilogue(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
