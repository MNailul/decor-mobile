import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _usersKey = 'users_db';

  Future<List<User>> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? usersJson = prefs.getString(_usersKey);
    if (usersJson != null) {
      final List<dynamic> decoded = jsonDecode(usersJson);
      return decoded.map((e) => User.fromJson(e)).toList();
    }
    
    // Default dummy user
    final dummyUser = User(
      id: 'u1',
      fullName: 'testing',
      email: 'testing@gmail.com',
      phone: '+49 172 884 9201',
      password: 'password',
      addresses: [
        Address(
          label: 'Architectural Studio',
          details: 'Kantstraße 152, Charlottenburg, Berlin',
        ),
      ],
    );
    await _saveUsers([dummyUser]);
    return [dummyUser];
  }

  Future<void> _saveUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(users.map((e) => e.toJson()).toList());
    await prefs.setString(_usersKey, encoded);
  }

  Future<User?> login(String email, String password) async {
    final users = await _getUsers();
    try {
      return users.firstWhere(
        (u) => u.email == email && u.password == password,
      );
    } catch (e) {
      return null; // Not found
    }
  }

  Future<User?> register(String fullName, String email, String password, String phone) async {
    final users = await _getUsers();
    
    // Check if email exists
    if (users.any((u) => u.email == email)) {
      return null;
    }

    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: fullName,
      email: email,
      phone: phone,
      password: password,
      addresses: [],
    );

    users.add(newUser);
    await _saveUsers(users);
    return newUser;
  }

  Future<void> updateUser(User updatedUser) async {
    final users = await _getUsers();
    final index = users.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      users[index] = updatedUser;
      await _saveUsers(users);
    }
  }
}
