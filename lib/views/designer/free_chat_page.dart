import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/designer_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import 'designer_booking_page.dart';

class FreeChatPage extends StatefulWidget {
  final DesignerModel designer;
  final int initialTimeLeft;

  const FreeChatPage({
    super.key,
    required this.designer,
    required this.initialTimeLeft,
  });

  @override
  State<FreeChatPage> createState() => _FreeChatPageState();
}

class _FreeChatPageState extends State<FreeChatPage> {
  late int timeLeft;
  Timer? _timer;
  final TextEditingController _messageController = TextEditingController();
  bool _isTimeUp = false;
  final ScrollController _scrollController = ScrollController();

  static const Color primaryColor = Color(0xFFB5733A);

  @override
  void initState() {
    super.initState();
    timeLeft = widget.initialTimeLeft;
    
    // Fetch messages from backend using ChatProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.fetchMessages(widget.designer.userId).then((_) {
        _scrollToBottom();
      });
      chatProvider.startPollingMessages(widget.designer.userId);
    });

    if (timeLeft > 0) {
      _startTimer();
    } else {
      _isTimeUp = true;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isTimeUp = true;
        });
        _showTimeUpModal();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    // Stop polling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<ChatProvider>(context, listen: false).stopPolling();
      }
    });
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.sendMessage(widget.designer.userId, text);
    _scrollToBottom();
  }

  void _showTimeUpModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.timer_off_outlined, color: Colors.red, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                'Time\'s Up!',
                style: GoogleFonts.epilogue(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your 10-minute free consultation session has ended. Continue the discussion by booking a consultation.',
                textAlign: TextAlign.center,
                style: GoogleFonts.epilogue(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DesignerBookingPage(designer: widget.designer),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'BOOK CONSULTATION',
                    style: GoogleFonts.epilogue(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to profile
                },
                child: Text(
                  'BACK TO PROFILE',
                  style: GoogleFonts.epilogue(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String get timerString {
    int minutes = timeLeft ~/ 60;
    int seconds = timeLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    bool isUrgent = timeLeft <= 60;
    final currentUser = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.orange.shade100,
              child: Text(
                widget.designer.fullName.isNotEmpty ? widget.designer.fullName[0].toUpperCase() : '?',
                style: GoogleFonts.epilogue(color: primaryColor, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.designer.fullName,
                  style: GoogleFonts.epilogue(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black),
                ),
                Text(
                  'FREE CONSULTATION',
                  style: GoogleFonts.epilogue(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green, letterSpacing: 1),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isUrgent ? Colors.red.shade50 : primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isUrgent ? Colors.red.shade100 : primaryColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 14, color: isUrgent ? Colors.red : primaryColor),
                const SizedBox(width: 6),
                Text(
                  timerString,
                  style: GoogleFonts.epilogue(
                    fontWeight: FontWeight.w900,
                    color: isUrgent ? Colors.red : primaryColor,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          final messages = chatProvider.messages;

          return Column(
            children: [
              Expanded(
                child: chatProvider.isLoading && messages.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(20),
                        itemCount: messages.length + 1, // +1 for the welcome message
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // Welcome mock message
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.orange.shade100,
                                    child: Text(
                                      widget.designer.fullName.isNotEmpty ? widget.designer.fullName[0].toUpperCase() : '?',
                                      style: GoogleFonts.epilogue(fontSize: 10, color: primaryColor, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                        bottomLeft: Radius.circular(0),
                                        bottomRight: Radius.circular(20),
                                      ),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))
                                      ],
                                    ),
                                    child: Text(
                                      'Hello! I\'m ${widget.designer.fullName}. How can I help you with your design project today? You have 10 minutes of free consultation.',
                                      style: GoogleFonts.epilogue(
                                        color: Colors.black87,
                                        fontSize: 13,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final msg = messages[index - 1];
                          final isMe = msg.senderId.toString() == currentUser?.id;
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (!isMe)
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.orange.shade100,
                                    child: Text(
                                      widget.designer.fullName.isNotEmpty ? widget.designer.fullName[0].toUpperCase() : '?',
                                      style: GoogleFonts.epilogue(fontSize: 10, color: primaryColor, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                Container(
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isMe ? primaryColor : Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(20),
                                      topRight: const Radius.circular(20),
                                      bottomLeft: Radius.circular(isMe ? 20 : 0),
                                      bottomRight: Radius.circular(isMe ? 0 : 20),
                                    ),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))
                                    ],
                                  ),
                                  child: Text(
                                    msg.message ?? '',
                                    style: GoogleFonts.epilogue(
                                      color: isMe ? Colors.white : Colors.black87,
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              
              // Input Area
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.black12)),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.attach_file, color: Colors.grey),
                        onPressed: _isTimeUp ? null : () {},
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            controller: _messageController,
                            enabled: !_isTimeUp,
                            decoration: InputDecoration(
                              hintText: 'Type your message...',
                              hintStyle: GoogleFonts.epilogue(fontSize: 14, color: Colors.grey),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: _isTimeUp ? null : _sendMessage,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _isTimeUp ? Colors.grey : primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.send, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
