import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<User> _conversations = [];
  List<ChatModel> _messages = [];
  bool _isLoading = false;
  Timer? _pollingTimer;

  List<User> get conversations => _conversations;
  List<ChatModel> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> fetchConversations() async {
    _isLoading = true;
    notifyListeners();

    try {
      _conversations = await _apiService.fetchConversations();
    } catch (e) {
      print('Error fetching conversations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMessages(int receiverId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _messages = await _apiService.fetchMessages(receiverId);
    } catch (e) {
      print('Error fetching messages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(int receiverId, String message, {int? productId}) async {
    try {
      ChatModel newMsg = await _apiService.sendMessage(receiverId, message, productId: productId);
      _messages.add(newMsg);
      notifyListeners();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  void startPollingMessages(int receiverId) {
    stopPolling();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final newMessages = await _apiService.fetchMessages(receiverId);
        if (newMessages.length > _messages.length) {
          _messages = newMessages;
          notifyListeners();
        }
      } catch (e) {
        // Ignore polling errors
      }
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
