import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/designer_model.dart';
import '../../providers/consultation_provider.dart';

class DesignerBookingPage extends StatefulWidget {
  final DesignerModel designer;

  const DesignerBookingPage({super.key, required this.designer});

  @override
  State<DesignerBookingPage> createState() => _DesignerBookingPageState();
}

class _DesignerBookingPageState extends State<DesignerBookingPage> {
  static const Color primaryColor = Color(0xFFB5733A);
  static const Color secondaryColor = Color(0xFFE3DCD6);
  static const Color textColor = Color(0xFF1E1E1E);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _briefController = TextEditingController();
  
  String? _selectedConsultationType;
  String? _selectedBudgetRange;
  
  final List<String> _consultationTypes = ['Chat Consultation', 'Request Proposal'];
  final List<String> _budgetRanges = ['Rp 5jt - 10jt', 'Rp 10jt - 50jt', 'Rp 50jt - 100jt', '> Rp 100jt'];

  bool _isLoading = false;

  double get totalPrice {
    if (_selectedConsultationType == 'Request Proposal') return 250000;
    return 50000; // Default for Chat Consultation
  }

  @override
  void dispose() {
    _titleController.dispose();
    _briefController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Book Consultation',
          style: GoogleFonts.epilogue(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Designer Info Snippet
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(widget.designer.image),
                    backgroundColor: secondaryColor,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.designer.studioName,
                          style: GoogleFonts.epilogue(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.designer.specialty,
                          style: GoogleFonts.epilogue(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Divider(color: Colors.grey.shade100, thickness: 8),
            
            // Title & Phase
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PHASE 1: REQUEST APPROVAL',
                    style: GoogleFonts.epilogue(
                      color: primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start Your Project',
                    style: GoogleFonts.epilogue(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Send a consultation request. Once approved, you can proceed to the initial consultation fee payment.',
                    style: GoogleFonts.epilogue(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: Colors.grey.shade100, thickness: 8),

            // Form Fields
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project Name
                  Text(
                    'Project Name',
                    style: GoogleFonts.epilogue(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'e.g., Minimalist Living Room Renovation',
                      hintStyle: GoogleFonts.epilogue(color: Colors.grey.shade400, fontSize: 14),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Consultation Type
                  Text(
                    'Consultation Type',
                    style: GoogleFonts.epilogue(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedConsultationType,
                    hint: Text('Select Consultation Type', style: GoogleFonts.epilogue(color: Colors.grey.shade400, fontSize: 14)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                    items: _consultationTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(
                          '$type (${type == 'Chat Consultation' ? 'Rp 50.000' : 'Rp 250.000'})',
                          style: GoogleFonts.epilogue(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedConsultationType = val;
                        if (val != 'Request Proposal') {
                          _selectedBudgetRange = null;
                          _briefController.clear();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  if (_selectedConsultationType == 'Request Proposal') ...[
                    // Budget Range
                    Text(
                      'Estimated Budget',
                      style: GoogleFonts.epilogue(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedBudgetRange,
                      hint: Text('Select Budget Range', style: GoogleFonts.epilogue(color: Colors.grey.shade400, fontSize: 14)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                      items: _budgetRanges.map((budget) {
                        return DropdownMenuItem(
                          value: budget,
                          child: Text(budget, style: GoogleFonts.epilogue(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedBudgetRange = val;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Project Brief
                    Text(
                      'Project Brief',
                      style: GoogleFonts.epilogue(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _briefController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Describe room details, color preferences, and design style...',
                        hintStyle: GoogleFonts.epilogue(color: Colors.grey.shade400, fontSize: 14),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 120), // Bottom padding for fixed button
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consultation Fee',
                    style: GoogleFonts.epilogue(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    totalPrice.toIDR(),
                    style: GoogleFonts.epilogue(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade100),
                      ),
                      child: Text(
                        'Fee ini komitmen awal. Biaya jasa desain akan dinegosiasikan kemudian.',
                        style: GoogleFonts.epilogue(fontSize: 7, color: Colors.amber.shade900, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 54,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_titleController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter Project Name')));
                            return;
                          }
                          if (_selectedConsultationType == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Consultation Type')));
                            return;
                          }
                           if (_selectedConsultationType == 'Request Proposal' && _selectedBudgetRange == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Estimated Budget')));
                            return;
                          }
                          if (_selectedConsultationType == 'Request Proposal' && _briefController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Project Brief is required for Request Proposal')));
                            return;
                          }

                          setState(() => _isLoading = true);
                          
                          // Format description to match web
                          final String finalDescription = "Jenis Konsultasi: $_selectedConsultationType\n\n" + 
                            (_briefController.text.trim().isEmpty ? 'Tidak ada brief tambahan.' : _briefController.text.trim());

                           final success = await context.read<ConsultationProvider>().bookConsultation(
                            designerId: widget.designer.id,
                            title: _titleController.text.trim(),
                            description: finalDescription,
                            budgetRange: _selectedConsultationType == 'Request Proposal'
                                ? _selectedBudgetRange!
                                : '-',
                            consultationType: _selectedConsultationType == 'Request Proposal'
                                ? 'request_proposal'
                                : 'chat_consultation',
                          );
                          
                          setState(() => _isLoading = false);

                          if (success) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Request sent! Waiting for designer approval.')),
                              );
                              Navigator.pop(context);
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(context.read<ConsultationProvider>().errorMessage ?? 'Failed to send request')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                            'Send Request',
                            style: GoogleFonts.epilogue(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
