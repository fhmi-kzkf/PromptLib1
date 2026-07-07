import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  int? _userId;
  String? _username;
  String? _email;
  String? _rank;

  int? get userId => _userId;
  String? get username => _username;
  String? get email => _email;
  String? get rank => _rank;
  bool get isLoggedIn => _userId != null;
  bool get isAdmin => _rank == 'Admin';

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getInt('userId');
      _username = prefs.getString('username');
      _email = prefs.getString('email');
      _rank = prefs.getString('rank');
      if (isLoggedIn) {
        debugPrint('[UserSession] Restored session for: $_username');
      }
    } catch (e) {
      debugPrint('[UserSession] Failed to initialize SharedPreferences: $e');
    }
  }

  Future<void> setUser(Map<String, dynamic> userData) async {
    _userId = userData['id'] is String ? int.tryParse(userData['id']) : userData['id'];
    _username = userData['username'];
    _email = userData['email'];
    _rank = userData['rank'];

    final prefs = await SharedPreferences.getInstance();
    if (_userId != null) await prefs.setInt('userId', _userId!);
    if (_username != null) await prefs.setString('username', _username!);
    if (_email != null) await prefs.setString('email', _email!);
    if (_rank != null) await prefs.setString('rank', _rank!);

    debugPrint('[UserSession] Logged in and saved as: $_username (ID: $_userId)');
  }

  Future<void> clear() async {
    _userId = null;
    _username = null;
    _email = null;
    _rank = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('username');
    await prefs.remove('email');
    await prefs.remove('rank');
    
    debugPrint('[UserSession] Session cleared from memory and storage.');
  }
}
