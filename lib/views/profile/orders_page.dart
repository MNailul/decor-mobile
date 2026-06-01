import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../order/track_order_page.dart';
import '../order/invoice_page.dart';
import 'write_review_page.dart';
import '../order/return_detail_page.dart';
import 'package:intl/intl.dart';
import '../../core/utils/currency_formatter.dart';
import '../cart/qr_payment_page.dart';
import '../../providers/cart_provider.dart';
import '../cart/cart_page.dart';
import '../order/return_request_page.dart';



import 'package:image_picker/image_picker.dart';
import 'dart:io';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  static const Color primaryColor = Color(0xFFB5733A);

  @override
  void initState() {
    super.initState();
    // Load orders when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
    });
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'MY ORDERS',
          style: GoogleFonts.epilogue(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }

          final orders = orderProvider.orders;

          if (orders.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () => orderProvider.loadOrders(),
            color: primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildOrderCard(context, order);
              },
            ),
          );
        },
      ),
    );
  }

  void _showReturnBottomSheet(BuildContext context, OrderModel order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReturnRequestPage(
          product: order.items.isNotEmpty ? order.items.first.product : null,
          orderId: order.id,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 24),
          Text(
            'No orders yet',
            style: GoogleFonts.epilogue(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your purchase history will appear here.',
            style: GoogleFonts.epilogue(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    final dateStr = DateFormat('MMM dd, yyyy').format(order.orderDate);
    final isProcessing = order.status == OrderStatus.processing;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getStatusText(order.status),
                      style: GoogleFonts.epilogue(
                        color: primaryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  if (order.returnStatus != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getReturnStatusColor(order.returnStatus!).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        order.returnStatus!.toUpperCase(),
                        style: GoogleFonts.epilogue(
                          color: _getReturnStatusColor(order.returnStatus!),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                dateStr,
                style: GoogleFonts.epilogue(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Order #${order.id}',
            style: GoogleFonts.epilogue(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Items Summary
          ...order.items.take(2).map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.product?.imageUrl ?? 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=200&q=80',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product?.name ?? 'Unknown Product',
                        style: GoogleFonts.epilogue(fontSize: 13, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Qty: ${item.quantity}',
                        style: GoogleFonts.epilogue(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                Text(
                  (item.price * item.quantity).toIDR(),
                  style: GoogleFonts.epilogue(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )),
          
          if (order.items.length > 2)
            Text(
              '+ ${order.items.length - 2} more items',
              style: GoogleFonts.epilogue(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
            ),

          const Divider(height: 32),
          
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL AMOUNT',
                        style: GoogleFonts.epilogue(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey.shade500),
                      ),
                      Text(
                        order.totalAmount.toIDR(),
                        style: GoogleFonts.epilogue(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InvoicePage(order: order),
                        ),
                      );
                    },
                    child: Text(
                      'INVOICE',
                      style: GoogleFonts.epilogue(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (order.status == OrderStatus.delivered && order.returnStatus == null && !order.hasReviewed) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showReturnBottomSheet(context, order),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Return Request',
                          style: GoogleFonts.epilogue(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                    Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (order.status == OrderStatus.shipped) {
                          // Show confirmation dialog
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Konfirmasi'),
                              content: const Text('Apakah Anda sudah menerima pesanan ini?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya, Sudah')),
                              ],
                            ),
                          );

                          if (confirm == true && context.mounted) {
                            final success = await context.read<OrderProvider>().completeOrder(order.id);
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Pesanan berhasil diselesaikan!')),
                              );
                            }
                          }
                          return;
                        }

                        if (order.status == OrderStatus.delivered) {
                          if (order.hasReviewed) {
                            // Buy Again logic: Add all items to cart and go to cart
                            final cart = context.read<CartProvider>();
                            final products = order.items
                                .where((i) => i.product != null)
                                .map((i) => i.product!.toFurnitureProduct())
                                .toList();
                            
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(child: CircularProgressIndicator(color: primaryColor)),
                            );

                            await cart.buyAgain(products);
                            
                            if (context.mounted) {
                              Navigator.pop(context); // close loading
                              // Show success snackbar
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Items added to cart!'),
                                  backgroundColor: primaryColor,
                                  action: SnackBarAction(
                                    label: 'VIEW CART',
                                    textColor: Colors.white,
                                    onPressed: () {
                                      // Since we are in OrdersPage (which is likely under Profile),
                                      // we might want to pop back to HomePage and switch tab,
                                      // but for now let's just go to CartPage directly.
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const CartPage()),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }
                          } else {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => WriteReviewPage(order: order),
                              ),
                            );
                          }
                        } else if (order.status == OrderStatus.returning) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReturnDetailPage(order: order),
                            ),
                          );
                        } else if (order.status == OrderStatus.pending) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BankTransferPage(amount: order.totalAmount, orderId: order.id),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TrackOrderPage(order: order),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (order.status == OrderStatus.shipped || (order.status == OrderStatus.delivered && order.hasReviewed)) ? primaryColor : Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        order.status == OrderStatus.shipped
                            ? 'Pesanan Diterima'
                            : (order.status == OrderStatus.delivered 
                                ? (order.hasReviewed ? 'Buy Again' : 'Leave Review') 
                                : (order.status == OrderStatus.returning ? 'Return Details' : (order.status == OrderStatus.pending ? 'Pay Now' : (isProcessing ? 'Track Order' : 'Order Details')))),
                        style: GoogleFonts.epilogue(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.processing:
        return 'DALAM PROSES';
      case OrderStatus.shipped:
        return 'DIKIRIM';
      case OrderStatus.delivered:
        return 'SELESAI';
      case OrderStatus.cancelled:
        return 'DIBATALKAN';
      case OrderStatus.returning:
        return 'RETURNING';
      default:
        return 'PENDING';
    }
  }

  Color _getReturnStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange; // pending
    }
  }
}

class ReturnRequestWidget extends StatefulWidget {
  final OrderModel order;
  final ScrollController scrollController;

  const ReturnRequestWidget({
    super.key,
    required this.order,
    required this.scrollController,
  });

  @override
  State<ReturnRequestWidget> createState() => _ReturnRequestWidgetState();
}

class _ReturnRequestWidgetState extends State<ReturnRequestWidget> {
  final Color primaryColor = const Color(0xFFB5733A);
  final Color secondaryColor = const Color(0xFFE3DCD6);
  
  String? selectedReason;
  final TextEditingController _descriptionController = TextEditingController();
  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> reasons = [
    'Barang Cacat/Rusak',
    'Tidak Sesuai Deskripsi',
    'Bagian Tidak Lengkap',
    'Salah Kirim Barang',
  ];

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _images.add(image);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Return Request',
                style: GoogleFonts.epilogue(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: ListView(
            controller: widget.scrollController,
            padding: const EdgeInsets.all(24.0),
            children: [
              // Product Info
              _buildProductInfoCard(),
              const SizedBox(height: 32),

              // Reason
              _buildSectionTitle('Alasan Pengembalian'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: reasons.map((reason) => _buildReasonChip(reason)).toList(),
              ),
              const SizedBox(height: 32),

              // Description
              _buildSectionTitle('Detail Masalah'),
              const SizedBox(height: 16),
              _buildDescriptionField(),
              const SizedBox(height: 32),

              // Upload Proof
              _buildSectionTitle('Unggah Bukti Foto'),
              const SizedBox(height: 16),
              _buildUploadContainer(),
              
              if (_images.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildImageGrid(),
              ],
              
              const SizedBox(height: 40),
              _buildSubmitButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.epilogue(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildProductInfoCard() {
    final product = widget.order.items.first.product;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product?.imageUrl ?? 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=200&q=80',
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
                  product?.name ?? 'Unknown Product',
                  style: GoogleFonts.epilogue(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Order ID: #${widget.order.id}',
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
    return GestureDetector(
      onTap: () => setState(() => selectedReason = reason),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? primaryColor : Colors.grey.shade300),
        ),
        child: Text(
          reason,
          style: GoogleFonts.epilogue(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 4,
      style: GoogleFonts.epilogue(fontSize: 13),
      decoration: InputDecoration(
        hintText: 'Describe the issue...',
        hintStyle: GoogleFonts.epilogue(color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildUploadContainer() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, color: primaryColor),
            const SizedBox(height: 8),
            Text(
              'Tap to upload photos',
              style: GoogleFonts.epilogue(fontSize: 12, color: primaryColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_images[index].path),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => setState(() => _images.removeAt(index)),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.close, color: Colors.white, size: 12),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (selectedReason == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select a reason')),
            );
            return;
          }

          final provider = context.read<OrderProvider>();
          
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white)),
          );

          final success = await provider.submitReturn(
            orderId: widget.order.id,
            reason: '$selectedReason - ${_descriptionController.text}',
            returnType: 'refund', // Default for fallback widget
            photoPath: _images.isNotEmpty ? _images.first.path : null,
          );

          if (context.mounted) Navigator.pop(context);

          if (success) {
            if (context.mounted) {
              Navigator.pop(context); // Close bottom sheet
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Return request submitted successfully')),
              );
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(provider.errorMessage ?? 'Failed to submit return')),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: Text(
          'Submit Return Request',
          style: GoogleFonts.epilogue(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
