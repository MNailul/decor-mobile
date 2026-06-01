import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/address_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/bounce_tap.dart';
import 'guest_profile_page.dart';
import 'address_management_page.dart';
import 'edit_profile_page.dart';
import 'orders_page.dart';
import 'returns_page.dart';
import 'consultation_history_page.dart';
import 'track_consultation_page.dart';
import '../wishlist/wishlist_page.dart';
import '../chat/chat_history_page.dart';
import 'help_center_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color textColor = Color(0xFF1E1E1E);
  static const Color lightTextColor = Color(0xFF757575);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AuthProvider>().isLoggedIn) {
        context.read<AddressProvider>().loadAddresses();
      }
    });
  }

  Future<void> _pickAndUploadImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null && mounted) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.uploadProfilePicture(image.path);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully!')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isLoggedIn) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: GuestProfilePage(),
          );
        }
        
        final user = authProvider.currentUser!;

        return Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: Text(
              'PROFILE',
              style: GoogleFonts.epilogue(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: 1.5,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.black, size: 22),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
            leading: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.black, size: 22),
              onPressed: () => authProvider.logout(),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await authProvider.refreshProfile();
              if (mounted) {
                await context.read<AddressProvider>().loadAddresses();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile synchronized with server'),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            color: AppColors.primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Header Section
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: Column(
                    children: [
                      BounceTap(
                        onTap: () => _pickAndUploadImage(context),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.secondaryColor.withOpacity(0.5), 
                                  width: 4
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColors.secondaryColor,
                                backgroundImage: (user.profilePicture != null && user.profilePicture!.isNotEmpty)
                                    ? NetworkImage(user.profilePicture!)
                                    : const NetworkImage('https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&q=80'),
                                child: authProvider.isLoading 
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black26,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2.5),
                              ),
                              padding: const EdgeInsets.all(5),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.fullName,
                        style: GoogleFonts.epilogue(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'PRO MEMBER SINCE 2022',
                          style: GoogleFonts.epilogue(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Quick Action Grid
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('QUICK ACTIONS'),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 16,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 48 - 48) / 5,
                            child: _buildQuickActionItem(
                              Icons.inventory_2_outlined, 
                              'Orders',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OrdersPage())),
                            ),
                          ),
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 48 - 48) / 5,
                            child: _buildQuickActionItem(
                              Icons.track_changes, 
                              'Track',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TrackConsultationPage())),
                            ),
                          ),
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 48 - 48) / 5,
                            child: _buildQuickActionItem(
                              Icons.event_note_outlined, 
                              'Consults',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ConsultationHistoryPage())),
                            ),
                          ),
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 48 - 48) / 5,
                            child: _buildQuickActionItem(
                              Icons.favorite_border_outlined, 
                              'Wishlist',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistPage())),
                            ),
                          ),
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 48 - 48) / 5,
                            child: _buildQuickActionItem(
                              Icons.chat_bubble_outline, 
                              'Chats',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatHistoryPage())),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Account Details Section
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionHeader('ACCOUNT ESSENTIALS'),
                          BounceTap(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilePage())),
                            child: Text(
                              'EDIT',
                              style: GoogleFonts.epilogue(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryColor,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildInfoRow(Icons.person_outline, 'Full Name', user.fullName),
                      const Divider(height: 32, thickness: 0.5),
                      _buildInfoRow(Icons.email_outlined, 'Email Address', user.email),
                      const Divider(height: 32, thickness: 0.5),
                      _buildInfoRow(Icons.phone_outlined, 'Phone Number', user.phone),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Delivery Destinations Section
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionHeader('DELIVERY DESTINATIONS'),
                          BounceTap(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressManagementPage())),
                            child: Text(
                              'MANAGE',
                              style: GoogleFonts.epilogue(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryColor,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Consumer<AddressProvider>(
                        builder: (context, addressProvider, child) {
                          final mainAddress = addressProvider.mainAddress;
                          if (mainAddress != null && mainAddress.id != 'default-1') {
                            return _buildAddressCard(
                              mainAddress.name.toLowerCase() == 'office' ? Icons.business_outlined : Icons.home_outlined,
                              '${mainAddress.name} (Main)',
                              mainAddress.fullAddress,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressManagementPage())),
                            );
                          }
                          
                          // If only default or no address, check user model
                          if (user.address.isNotEmpty) {
                            return _buildAddressCard(
                              Icons.home_outlined,
                              'Profile Address (Main)',
                              '${user.address}, ${user.city}',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressManagementPage())),
                            );
                          }

                          return _buildAddressCard(
                            Icons.location_on_outlined,
                            'No Address Yet',
                            'Add a new delivery destination',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressManagementPage())),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Support & Help Section
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('SUPPORT & HELP'),
                      const SizedBox(height: 16),
                      _buildAddressCard(
                        Icons.help_outline_rounded,
                        'Help Center',
                        'Submit complaints and check history',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HelpCenterPage()),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100), // Spacing for floating dock
              ],
            ),
          ),
        ),
      );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.epilogue(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: lightTextColor,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildQuickActionItem(IconData icon, String label, {VoidCallback? onTap}) {
    return BounceTap(
      onTap: onTap ?? () {},
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.epilogue(
              fontWeight: FontWeight.w600,
              color: textColor,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.secondaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.primaryColor),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.epilogue(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: lightTextColor,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.epilogue(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddressCard(IconData icon, String title, String address, {VoidCallback? onTap}) {
    return BounceTap(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: textColor, size: 22),
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
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address,
                    style: GoogleFonts.epilogue(
                      fontSize: 12,
                      color: lightTextColor,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: lightTextColor, size: 20),
          ],
        ),
      ),
    );
  }
}

