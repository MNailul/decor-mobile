import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/address_provider.dart';
import '../../models/address_model.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/bounce_tap.dart';
import 'address_form_page.dart';

class AddressManagementPage extends StatelessWidget {
  const AddressManagementPage({super.key});

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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'MY ADDRESSES',
          style: GoogleFonts.epilogue(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: Consumer<AddressProvider>(
        builder: (context, provider, child) {
          final addresses = provider.addresses;
          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.location_off_outlined, size: 48, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'NO ADDRESSES FOUND',
                    style: GoogleFonts.epilogue(
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a new delivery destination\nto start shopping.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.epilogue(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemCount: addresses.length + 1,
            itemBuilder: (context, index) {
              if (index == addresses.length) {
                return const SizedBox(height: 100); // Space for dock
              }
              final address = addresses[index];
              return _buildAddressCard(context, address, provider);
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -4),
              blurRadius: 20,
            ),
          ],
        ),
        child: SafeArea(
          child: BounceTap(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddressFormPage()),
              );
            },
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'ADD NEW ADDRESS',
                  style: GoogleFonts.epilogue(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, AddressModel address, AddressProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: address.isMain ? AppColors.primaryColor : const Color(0xFFF0F0F0),
          width: address.isMain ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: address.isMain ? AppColors.primaryColor.withOpacity(0.05) : const Color(0xFFF8F8F8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        address.name.toLowerCase() == 'office' ? Icons.business_rounded : Icons.home_rounded,
                        size: 18,
                        color: address.isMain ? AppColors.primaryColor : Colors.black54,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        address.name.toUpperCase(),
                        style: GoogleFonts.epilogue(
                          color: address.isMain ? AppColors.primaryColor : Colors.black87,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  if (address.isMain)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'MAIN',
                        style: GoogleFonts.epilogue(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.recipientName,
                    style: GoogleFonts.epilogue(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    address.phoneNumber,
                    style: GoogleFonts.epilogue(
                      color: Colors.black54,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    address.fullAddress,
                    style: GoogleFonts.epilogue(
                      color: Colors.black87,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: BounceTap(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddressFormPage(addressToEdit: address),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F8F8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFF0F0F0)),
                            ),
                            child: Center(
                              child: Text(
                                'EDIT',
                                style: GoogleFonts.epilogue(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: Colors.black87,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (!address.isMain)
                        Expanded(
                          child: BounceTap(
                            onTap: () => provider.setMainAddress(address.id),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primaryColor),
                              ),
                              child: Center(
                                child: Text(
                                  'SET MAIN',
                                  style: GoogleFonts.epilogue(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: AppColors.primaryColor,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (!address.isMain) const SizedBox(width: 12),
                      BounceTap(
                        onTap: () => provider.deleteAddress(address.id),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
