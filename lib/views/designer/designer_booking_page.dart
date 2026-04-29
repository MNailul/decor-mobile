import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './consultation_payment_page.dart';

class DesignerBookingPage extends StatefulWidget {
  final Map<String, dynamic> designer;

  const DesignerBookingPage({super.key, required this.designer});

  @override
  State<DesignerBookingPage> createState() => _DesignerBookingPageState();
}

class _DesignerBookingPageState extends State<DesignerBookingPage> {
  static const Color primaryColor = Color(0xFFB5733A);
  static const Color secondaryColor = Color(0xFFE3DCD6);
  static const Color textColor = Color(0xFF1E1E1E);

  String selectedConsultationType = 'Video Call';
  int selectedDateIndex = 0;
  int selectedTimeIndex = 0;
  final TextEditingController _briefController = TextEditingController();

  final List<Map<String, dynamic>> consultationTypesData = [
    {
      'type': 'Chat',
      'duration': '1 Hour',
      'priceMultiplier': 0.5,
      'desc': 'Text consultation via app. Great for quick questions.',
    },
    {
      'type': 'Video Call',
      'duration': '1 Hour',
      'priceMultiplier': 1.0,
      'desc': 'Virtual face-to-face. Ideal for floor plan review.',
    },
    {
      'type': 'On-Site',
      'duration': '2 Hours',
      'priceMultiplier': 2.5,
      'desc': 'Designer visits your location. Includes measurements.',
    },
  ];

  int getBasePrice() {
    String priceStr = widget.designer['price'].toString().replaceAll(RegExp(r'[^0-9]'), '');
    int parsed = int.tryParse(priceStr) ?? 500;
    if (parsed < 10000) {
      parsed = parsed * 1000;
    }
    return parsed;
  }

  String formatCurrency(double amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1).replaceAll('.0', '')}jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toInt()}k';
    }
    return 'Rp ${amount.toInt()}';
  }
  
  // Dummy dates
  final List<Map<String, String>> availableDates = [
    {'day': 'Mon', 'date': '12'},
    {'day': 'Tue', 'date': '13'},
    {'day': 'Wed', 'date': '14'},
    {'day': 'Thu', 'date': '15'},
    {'day': 'Fri', 'date': '16'},
    {'day': 'Sat', 'date': '17'},
  ];

  // Dummy times
  final List<String> availableTimes = [
    '09:00 AM',
    '10:30 AM',
    '01:00 PM',
    '03:30 PM',
    '05:00 PM',
  ];

  @override
  void dispose() {
    _briefController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedData = consultationTypesData.firstWhere((d) => d['type'] == selectedConsultationType);
    final totalPrice = getBasePrice() * (selectedData['priceMultiplier'] as double);

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
                    backgroundImage: NetworkImage(widget.designer['image']),
                    backgroundColor: secondaryColor,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.designer['name'],
                          style: GoogleFonts.epilogue(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.designer['specialty'],
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
            
            // Consultation Type
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consultation Type',
                    style: GoogleFonts.epilogue(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: consultationTypesData.map((data) {
                      final type = data['type'] as String;
                      final isSelected = selectedConsultationType == type;
                      final price = getBasePrice() * (data['priceMultiplier'] as double);
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedConsultationType = type;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryColor.withOpacity(0.05) : Colors.white,
                            border: Border.all(
                              color: isSelected ? primaryColor : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? primaryColor : Colors.grey.shade400,
                                    width: isSelected ? 6 : 2,
                                  ),
                                ),
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
                                          type,
                                          style: GoogleFonts.epilogue(
                                            color: textColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          formatCurrency(price),
                                          style: GoogleFonts.epilogue(
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${data['duration']} • ${data['desc']}',
                                      style: GoogleFonts.epilogue(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            Divider(color: Colors.grey.shade100, thickness: 8),

            // Date & Time Selection
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Date',
                    style: GoogleFonts.epilogue(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: availableDates.length,
                      itemBuilder: (context, index) {
                        final date = availableDates[index];
                        final isSelected = selectedDateIndex == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDateIndex = index;
                            });
                          },
                          child: Container(
                            width: 60,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryColor : Colors.white,
                              border: Border.all(
                                color: isSelected ? primaryColor : Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  date['day']!,
                                  style: GoogleFonts.epilogue(
                                    color: isSelected ? Colors.white.withOpacity(0.8) : Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  date['date']!,
                                  style: GoogleFonts.epilogue(
                                    color: isSelected ? Colors.white : textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Text(
                    'Select Time',
                    style: GoogleFonts.epilogue(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: availableTimes.asMap().entries.map((entry) {
                      final index = entry.key;
                      final time = entry.value;
                      final isSelected = selectedTimeIndex == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTimeIndex = index;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryColor : Colors.white,
                            border: Border.all(
                              color: isSelected ? primaryColor : Colors.grey.shade300,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            time,
                            style: GoogleFonts.epilogue(
                              color: isSelected ? Colors.white : textColor,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            Divider(color: Colors.grey.shade100, thickness: 8),

            // Project Brief
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Project Brief (Optional)',
                    style: GoogleFonts.epilogue(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tell the designer a little bit about what you need help with.',
                    style: GoogleFonts.epilogue(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _briefController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'e.g., I want to redesign my 3x4m living room to look more minimalist...',
                      hintStyle: GoogleFonts.epilogue(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 100), // Bottom padding for fixed button
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
                    'Total Price',
                    style: GoogleFonts.epilogue(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    formatCurrency(totalPrice),
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
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      final selectedDate = DateTime(2024, 4, int.parse(availableDates[selectedDateIndex]['date']!));
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConsultationPaymentPage(
                            designer: widget.designer,
                            consultationType: selectedConsultationType,
                            date: selectedDate,
                            time: availableTimes[selectedTimeIndex],
                            totalPrice: totalPrice,
                            projectBrief: _briefController.text,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Continue',
                      style: GoogleFonts.epilogue(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
