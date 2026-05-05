import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class ChatDetailPage extends StatefulWidget {
  final String shopName;
  const ChatDetailPage({super.key, required this.shopName});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  void _sendMessage({String? quickText}) {
    final messageText = quickText ?? _messageController.text;
    if (messageText.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'isMe': true,
        'text': messageText,
        'time': '10:11 AM',
      });
      if (quickText == null) _messageController.clear();
    });

    // Auto-reply Simulation
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          String reply = 'Baik kak, mohon ditunggu sebentar ya. Saya cek dulu detailnya.';
          if (messageText.contains('promo')) reply = 'Sedang ada promo gratis ongkir kak khusus minggu ini!';
          if (messageText.contains('ready')) reply = 'Stok ready banyak kak, siap kirim!';
          if (messageText.contains('kasih')) reply = 'Sama-sama kak! Senang bisa membantu. Ada lagi yang bisa kami bantu?';
          
          _messages.add({
            'isMe': false,
            'text': reply,
            'time': '10:12 AM',
          });
        });
      }
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E)),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1541746972996-4e0b0f43e01a?w=100&q=80'),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.shopName,
                  style: GoogleFonts.epilogue(
                    color: const Color(0xFF1E1E1E),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'ONLINE • SHOP REPRESENTATIVE',
                  style: GoogleFonts.epilogue(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Color(0xFF1E1E1E)),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Sub-header (Consistent with Designer Page)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                Text(
                  'INQUIRY REGARDING:',
                  style: GoogleFonts.epilogue(
                    color: Colors.grey.shade500,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'FURNITURE COLLECTION',
                  style: GoogleFonts.epilogue(
                    color: AppColors.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          // Quick Chat Section
          Container(
            height: 50,
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _buildQuickChatChip('Apakah produk ready?'),
                _buildQuickChatChip('Bisa kirim hari ini?'),
                _buildQuickChatChip('Ada promo diskon?'),
                _buildQuickChatChip('Terima kasih!'),
              ],
            ),
          ),

          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    bool isMe = msg['isMe'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMe) ...[
                const CircleAvatar(
                  radius: 14,
                  backgroundImage: NetworkImage('https://images.unsplash.com/photo-1541746972996-4e0b0f43e01a?w=100&q=80'),
                ),
                const SizedBox(width: 12),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.grey.shade100 : AppColors.primaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    msg['text'],
                    style: GoogleFonts.epilogue(
                      color: isMe ? const Color(0xFF1E1E1E) : Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.only(left: isMe ? 0 : 40, right: isMe ? 4 : 0),
            child: Text(
              '${!isMe ? "SHOP REPRESENTATIVE • " : ""}${msg['time']}',
              style: GoogleFonts.epilogue(
                color: Colors.grey.shade400,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            _buildActionButton(Icons.storefront_outlined, 'STORE'),
            const SizedBox(width: 8),
            _buildActionButton(Icons.local_offer_outlined, 'OFFERS'),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'TYPE YOUR MESSAGE...',
                    hintStyle: GoogleFonts.epilogue(
                      color: Colors.grey.shade400,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  style: GoogleFonts.epilogue(fontSize: 14),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _sendMessage(),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Icon(icon, color: Colors.grey.shade400, size: 18),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.epilogue(
            color: Colors.grey.shade400,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickChatChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(
          text,
          style: GoogleFonts.epilogue(
            fontSize: 12,
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.secondaryColor.withOpacity(0.3),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () => _sendMessage(quickText: text),
      ),
    );
  }
}
