import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/address_provider.dart';
import '../../models/address_model.dart';
import '../../core/theme/app_colors.dart';

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
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'EDIT ADDRESS' : 'ADD ADDRESS',
          style: GoogleFonts.epilogue(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Address Label (e.g. Home, Office)',
                validator: (value) => value!.isEmpty ? 'Please enter a label' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _recipientNameController,
                label: 'Recipient Name',
                validator: (value) => value!.isEmpty ? 'Please enter recipient name' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _phoneNumberController,
                label: 'Phone Number',
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Please enter phone number' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _fullAddressController,
                label: 'Full Address',
                maxLines: 4,
                validator: (value) => value!.isEmpty ? 'Please enter full address' : null,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Checkbox(
                    value: _isMain,
                    activeColor: AppColors.primaryColor,
                    onChanged: (value) {
                      setState(() {
                        _isMain = value ?? false;
                      });
                    },
                  ),
                  Text(
                    'Set as Main Address',
                    style: GoogleFonts.epilogue(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF9F6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _saveAddress,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'SAVE ADDRESS',
              style: GoogleFonts.epilogue(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.epilogue(
            color: Colors.black54,
            fontWeight: FontWeight.w600,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.epilogue(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryColor),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
