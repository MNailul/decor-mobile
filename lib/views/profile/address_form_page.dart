import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/address_provider.dart';
import '../../models/address_model.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/bounce_tap.dart';

class AddressFormPage extends StatefulWidget {
  final AddressModel? addressToEdit;

  const AddressFormPage({super.key, this.addressToEdit});

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _recipientNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _fullAddressController;
  bool _isMain = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.addressToEdit?.name ?? '');
    _recipientNameController = TextEditingController(text: widget.addressToEdit?.recipientName ?? '');
    _phoneNumberController = TextEditingController(text: widget.addressToEdit?.phoneNumber ?? '');
    _fullAddressController = TextEditingController(text: widget.addressToEdit?.fullAddress ?? '');
    _isMain = widget.addressToEdit?.isMain ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _recipientNameController.dispose();
    _phoneNumberController.dispose();
    _fullAddressController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<AddressProvider>();
      
      final newAddress = AddressModel(
        id: widget.addressToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        recipientName: _recipientNameController.text,
        phoneNumber: _phoneNumberController.text,
        fullAddress: _fullAddressController.text,
        isMain: _isMain,
      );

      if (widget.addressToEdit == null) {
        provider.addAddress(newAddress);
      } else {
        provider.updateAddress(newAddress);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.addressToEdit != null;

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
          isEditing ? 'EDIT ADDRESS' : 'ADD NEW ADDRESS',
          style: GoogleFonts.epilogue(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('LABEL'),
              _buildTextField(
                controller: _nameController,
                hint: 'e.g. Home, Office, Apartment',
                validator: (value) => value!.isEmpty ? 'Please enter a label' : null,
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('RECIPIENT INFO'),
              _buildTextField(
                controller: _recipientNameController,
                hint: 'Full Name',
                validator: (value) => value!.isEmpty ? 'Please enter recipient name' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneNumberController,
                hint: 'Phone Number',
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Please enter phone number' : null,
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('LOCATION DETAILS'),
              _buildTextField(
                controller: _fullAddressController,
                hint: 'Street Name, House No, City, etc.',
                maxLines: 4,
                validator: (value) => value!.isEmpty ? 'Please enter full address' : null,
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF0F0F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SET AS MAIN',
                          style: GoogleFonts.epilogue(
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            letterSpacing: 1,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Make this your default address',
                          style: GoogleFonts.epilogue(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    Switch.adaptive(
                      value: _isMain,
                      activeColor: AppColors.primaryColor,
                      onChanged: (value) {
                        setState(() {
                          _isMain = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
            onTap: _saveAddress,
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
                  'SAVE ADDRESS',
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4),
      child: Text(
        title,
        style: GoogleFonts.epilogue(
          color: Colors.black45,
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.epilogue(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.epilogue(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF8F8F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }
}
