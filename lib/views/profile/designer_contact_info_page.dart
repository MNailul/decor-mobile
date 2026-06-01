import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/consultation_model.dart';
import 'package:url_launcher/url_launcher.dart';

class DesignerContactInfoPage extends StatelessWidget {
  final ConsultationModel consultation;

  const DesignerContactInfoPage({super.key, required this.consultation});

  static const Color primaryColor = Color(0xFFB5733A);
  static const Color textColor = Color(0xFF1E1E1E);

  @override
  Widget build(BuildContext context) {
    List<ConsultationAttachmentModel> mediaAssets = [];
    List<ConsultationAttachmentModel> docsAssets = [];

    if (consultation.attachments != null) {
      for (var item in consultation.attachments!) {
        bool isImage = item.fileType.toLowerCase().contains('png') || 
                       item.fileType.toLowerCase().contains('jpg') || 
                       item.fileType.toLowerCase().contains('jpeg') ||
                       item.fileType.toLowerCase().contains('webp') ||
                       item.fileType.toLowerCase().contains('image');
        if (isImage) {
          mediaAssets.add(item);
        } else {
          docsAssets.add(item);
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Contact Info',
          style: GoogleFonts.epilogue(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              color: Colors.white,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(consultation.fullDesignerImage ?? 'https://ui-avatars.com/api/?name=${consultation.designerName}'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    consultation.designerName ?? 'Designer',
                    style: GoogleFonts.epilogue(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Design Consultant',
                    style: GoogleFonts.epilogue(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Media, Links, and Docs',
                    style: GoogleFonts.epilogue(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor),
                  ),
                  const SizedBox(height: 16),
                  if (mediaAssets.isEmpty && docsAssets.isEmpty && (consultation.quotes == null || consultation.quotes!.isEmpty))
                    Text('No media or documents shared yet.', style: GoogleFonts.epilogue(color: Colors.grey, fontSize: 12))
                  else
                    DefaultTabController(
                      length: 3,
                      child: Column(
                        children: [
                          TabBar(
                            labelColor: primaryColor,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: primaryColor,
                            labelStyle: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 12),
                            tabs: const [
                              Tab(text: 'Media'),
                              Tab(text: 'Docs'),
                              Tab(text: 'Quotes/RAB'),
                            ],
                          ),
                          SizedBox(
                            height: 400,
                            child: TabBarView(
                              children: [
                                _buildMediaGrid(mediaAssets),
                                _buildDocsList(docsAssets),
                                _buildQuotesList(consultation.quotes ?? []),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaGrid(List<ConsultationAttachmentModel> mediaAssets) {
    if (mediaAssets.isEmpty) return Center(child: Text('No media', style: GoogleFonts.epilogue(color: Colors.grey, fontSize: 12)));
    return GridView.builder(
      padding: const EdgeInsets.only(top: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: mediaAssets.length,
      itemBuilder: (context, index) {
        return Image.network(
          mediaAssets[index].fullUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
        );
      },
    );
  }

  Widget _buildDocsList(List<ConsultationAttachmentModel> docsAssets) {
    if (docsAssets.isEmpty) return Center(child: Text('No documents', style: GoogleFonts.epilogue(color: Colors.grey, fontSize: 12)));
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16),
      itemCount: docsAssets.length,
      itemBuilder: (context, index) {
        final item = docsAssets[index];
        return ListTile(
          leading: const Icon(Icons.insert_drive_file, color: Colors.red),
          title: Text(item.fileUrl.split('/').last, style: GoogleFonts.epilogue(fontSize: 12, fontWeight: FontWeight.bold)),
          subtitle: Text('${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}', style: GoogleFonts.epilogue(fontSize: 10)),
          onTap: () => launchUrl(Uri.parse(item.fullUrl), mode: LaunchMode.externalApplication),
        );
      },
    );
  }

  Widget _buildQuotesList(List<ConsultationQuoteModel> quotes) {
    if (quotes.isEmpty) return Center(child: Text('No quotes/RAB', style: GoogleFonts.epilogue(color: Colors.grey, fontSize: 12)));
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16),
      itemCount: quotes.length,
      itemBuilder: (context, index) {
        final quote = quotes[index];
        return ListTile(
          leading: const Icon(Icons.request_quote, color: Colors.green),
          title: Text('Quote Rp ${quote.amount}', style: GoogleFonts.epilogue(fontSize: 12, fontWeight: FontWeight.bold)),
          subtitle: Text(quote.status.toUpperCase(), style: GoogleFonts.epilogue(fontSize: 10, color: _getStatusColor(quote.status))),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted': return Colors.green;
      case 'rejected': return Colors.red;
      case 'revision': return Colors.orange;
      default: return Colors.blue;
    }
  }
}
