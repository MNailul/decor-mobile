import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/consultation_provider.dart';
import '../../models/consultation_model.dart';
import 'consultation_chat_page.dart';

class ConsultationHistoryPage extends StatelessWidget {
  const ConsultationHistoryPage({super.key});

  static const Color primaryColor = Color(0xFFB5733A);
  static const Color textColor = Color(0xFF1E1E1E);

  String formatCurrency(double amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1).replaceAll('.0', '')}jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toInt()}k';
    }
    return 'Rp ${amount.toInt()}';
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
          icon: const Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Consultations',
          style: GoogleFonts.epilogue(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Consumer<ConsultationProvider>(
        builder: (context, provider, child) {
          if (provider.consultations.isEmpty) {
            return _buildEmptyState(context);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: provider.consultations.length,
            itemBuilder: (context, index) {
              final consultation = provider.consultations[index];
              return _buildConsultationCard(context, consultation);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note_outlined, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 24),
          Text(
            'No consultations yet',
            style: GoogleFonts.epilogue(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Book your first consultation with\nour expert designers.',
            textAlign: TextAlign.center,
            style: GoogleFonts.epilogue(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              'Explore Designers',
              style: GoogleFonts.epilogue(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationCard(BuildContext context, ConsultationModel consultation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    consultation.designerImage,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        consultation.designerName,
                        style: GoogleFonts.epilogue(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        consultation.consultationType,
                        style: GoogleFonts.epilogue(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(consultation.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    consultation.status.name.toUpperCase(),
                    style: GoogleFonts.epilogue(
                      color: _getStatusColor(consultation.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 8),
                        Text(
                          '${consultation.date.day}/${consultation.date.month}/${consultation.date.year}',
                          style: GoogleFonts.epilogue(fontSize: 13, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 8),
                        Text(
                          consultation.time,
                          style: GoogleFonts.epilogue(fontSize: 13, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      consultation.isFullPayment ? 'Full Payment' : 'DP (30%) Paid',
                      style: GoogleFonts.epilogue(fontSize: 11, color: Colors.grey.shade500),
                    ),
                    Text(
                      formatCurrency(consultation.paidAmount),
                      style: GoogleFonts.epilogue(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (consultation.status == ConsultationStatus.scheduled)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: OutlinedButton(
                onPressed: () {
                  if (consultation.consultationType == 'Chat') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConsultationChatPage(consultation: consultation),
                      ),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: primaryColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  consultation.consultationType == 'Chat' ? 'Start Chat' : 'Join Meeting',
                  style: GoogleFonts.epilogue(color: primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(ConsultationStatus status) {
    switch (status) {
      case ConsultationStatus.pending: return Colors.orange;
      case ConsultationStatus.scheduled: return Colors.blue;
      case ConsultationStatus.completed: return Colors.green;
      case ConsultationStatus.cancelled: return Colors.red;
    }
  }
}
