import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/address_provider.dart';
import '../../models/address_model.dart';
import 'qr_payment_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // Colors defined in the prompt
  static const Color primaryColor = Color(0xFFB5733A);
  static const Color secondaryColor = Color(0xFFE3DCD6);
  static const Color textColor = Color(0xFF1E1E1E);
  static const Color lightTextColor = Color(0xFF757575);

  // State for shipping/payment
  double shippingPrice = 15.0;
  final double taxes = 24.40; // Static for design consistency

  String selectedPaymentMethod = 'QR Code';
  String selectedShippingMethod = 'Curated Delivery';
  AddressModel? selectedAddress;

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final selectedItems = cartProvider.selectedItems;
        final subtotal = cartProvider.totalAmount;
        final grandTotal = subtotal + shippingPrice + taxes;

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
              'CHECKOUT',
              style: GoogleFonts.epilogue(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: 1.5,
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  children: [
                    _buildAddressCard(),
                    const SizedBox(height: 20),
                    _buildShippingMethodCard(),
                    const SizedBox(height: 20),
                    _buildPaymentMethodCard(),
                    const SizedBox(height: 32),
                    Text(
                      'ORDER SUMMARY',
                      style: GoogleFonts.epilogue(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Dynamic product list
                    ...selectedItems.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _buildProductItem(
                            imageUrl: item.product.imagePath,
                            name: item.product.name,
                            price: item.product.price * item.quantity,
                            quantity: item.quantity,
                            onMinus: () {
                              cartProvider.decrementQuantity(item.product.id);
                            },
                            onPlus: () {
                              cartProvider.incrementQuantity(item.product.id);
                            },
                          ),
                        )),
                    const SizedBox(height: 12),
                    _buildPriceBreakdown(subtotal, grandTotal),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              _buildBottomBar(grandTotal),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddressCard() {
    return Consumer<AddressProvider>(
      builder: (context, provider, child) {
        final address = selectedAddress ?? provider.mainAddress;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: secondaryColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SHIPPING ADDRESS',
                    style: GoogleFonts.epilogue(
                      color: lightTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) => _buildAddressSelector(provider),
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
              const SizedBox(height: 12),
              if (address != null) ...[
                Text(
                  address.recipientName,
                  style: GoogleFonts.epilogue(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  address.fullAddress,
                  style: GoogleFonts.epilogue(
                    color: lightTextColor,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address.phoneNumber,
                  style: GoogleFonts.epilogue(
                    color: lightTextColor,
                    fontSize: 14,
                  ),
                ),
              ] else ...[
                Text(
                  'No address selected',
                  style: GoogleFonts.epilogue(
                    color: lightTextColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildShippingMethodCard() {
    bool isCurated = selectedShippingMethod == 'Curated Delivery';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: secondaryColor),
      ),
      child: Row(
        children: [
          Icon(isCurated ? Icons.local_shipping_outlined : Icons.flight_takeoff, color: textColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedShippingMethod,
                  style: GoogleFonts.epilogue(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isCurated ? 'Est. 2-3 Business Days' : 'Est. 1 Business Day',
                  style: GoogleFonts.epilogue(
                    color: lightTextColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${shippingPrice.toStringAsFixed(2)}',
            style: GoogleFonts.epilogue(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => _buildShippingSelector(),
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

  Widget _buildShippingSelector() {
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
            'Select Shipping Method',
            style: GoogleFonts.epilogue(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.local_shipping_outlined, color: textColor),
            title: Text(
              'Curated Delivery',
              style: GoogleFonts.epilogue(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            subtitle: Text('Est. 2-3 Business Days', style: GoogleFonts.epilogue(fontSize: 12)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('\$15.00', style: GoogleFonts.epilogue(fontWeight: FontWeight.w600, color: textColor)),
                if (selectedShippingMethod == 'Curated Delivery') ...[
                  const SizedBox(width: 16),
                  const Icon(Icons.check_circle, color: primaryColor),
                ],
              ],
            ),
            onTap: () {
              setState(() {
                selectedShippingMethod = 'Curated Delivery';
                shippingPrice = 15.0;
              });
              Navigator.pop(context);
            },
          ),
          const Divider(color: secondaryColor),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.flight_takeoff, color: textColor),
            title: Text(
              'Express Shipping',
              style: GoogleFonts.epilogue(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            subtitle: Text('Est. 1 Business Day', style: GoogleFonts.epilogue(fontSize: 12)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('\$35.00', style: GoogleFonts.epilogue(fontWeight: FontWeight.w600, color: textColor)),
                if (selectedShippingMethod == 'Express Shipping') ...[
                  const SizedBox(width: 16),
                  const Icon(Icons.check_circle, color: primaryColor),
                ],
              ],
            ),
            onTap: () {
              setState(() {
                selectedShippingMethod = 'Express Shipping';
                shippingPrice = 35.0;
              });
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAddressSelector(AddressProvider provider) {
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
            'Select Shipping Address',
            style: GoogleFonts.epilogue(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 24),
          if (provider.addresses.isEmpty)
            Text('No addresses available.', style: GoogleFonts.epilogue(color: lightTextColor))
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: provider.addresses.length,
                separatorBuilder: (context, index) => const Divider(color: secondaryColor),
                itemBuilder: (context, index) {
                  final addr = provider.addresses[index];
                  final isSelected = selectedAddress?.id == addr.id || (selectedAddress == null && addr.isMain);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(addr.name.toLowerCase() == 'office' ? Icons.business : Icons.home_outlined, color: textColor),
                    title: Text(
                      '${addr.name} ${addr.isMain ? "(Main)" : ""}',
                      style: GoogleFonts.epilogue(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    subtitle: Text(addr.fullAddress, style: GoogleFonts.epilogue(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: primaryColor)
                        : null,
                    onTap: () {
                      setState(() => selectedAddress = addr);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProductItem({
    required String imageUrl,
    required String name,
    required double price,
    required int quantity,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 80,
              height: 80,
              color: secondaryColor,
              child: const Icon(Icons.image, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.epilogue(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              _buildQuantitySelector(quantity, onMinus, onPlus),
            ],
          ),
        ),
        Text(
          '\$${price.toStringAsFixed(2)}',
          style: GoogleFonts.epilogue(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector(int quantity, VoidCallback onMinus, VoidCallback onPlus) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onMinus,
          child: Container(
            padding: const EdgeInsets.all(4),
            child: const Icon(Icons.remove, color: primaryColor, size: 18),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          quantity.toString(),
          style: GoogleFonts.epilogue(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onPlus,
          child: Container(
            padding: const EdgeInsets.all(4),
            child: const Icon(Icons.add, color: primaryColor, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceBreakdown(double subtotal, double grandTotal) {
    return Column(
      children: [
        _buildPriceRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
        const SizedBox(height: 12),
        _buildPriceRow('Shipping', '\$${shippingPrice.toStringAsFixed(2)}'),
        const SizedBox(height: 12),
        _buildPriceRow('Taxes', '\$${taxes.toStringAsFixed(2)}'),
        const SizedBox(height: 24),
        const Divider(color: secondaryColor, thickness: 1),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: GoogleFonts.epilogue(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            Text(
              '\$${grandTotal.toStringAsFixed(2)}',
              style: GoogleFonts.epilogue(
                color: primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String amount) {
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
          amount,
          style: GoogleFonts.epilogue(
            color: lightTextColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(double grandTotal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                  '\$${grandTotal.toStringAsFixed(2)}',
                  style: GoogleFonts.epilogue(
                    color: primaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedPaymentMethod == 'QR Code') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QrPaymentPage(amount: grandTotal),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Virtual Account payment not implemented yet.')),
                  );
                }
              },
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
    );
  }
}
