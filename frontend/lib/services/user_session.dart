import 'package:flutter/foundation.dart';

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

  void setUser(Map<String, dynamic> userData) {
    _userId = userData['id'] is String ? int.tryParse(userData['id']) : userData['id'];
    _username = userData['username'];
    _email = userData['email'];
    _rank = userData['rank'];
    debugPrint('[UserSession] Logged in as: $_username (ID: $_userId)');
  }

  void clear() {
    _userId = null;
    _username = null;
    _email = null;
    _rank = null;
    debugPrint('[UserSession] Session cleared.');
  }
}
