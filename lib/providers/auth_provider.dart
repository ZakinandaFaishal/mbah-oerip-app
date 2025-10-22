import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AuthProvider extends ChangeNotifier {
  final Box _userBox = Hive.box('users');
  final Box _sessionBox = Hive.box('session');

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  String? _loggedInUser;
  String? get loggedInUser => _loggedInUser;

  AuthProvider() {
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    _loggedInUser = _sessionBox.get('currentUser');
    if (_loggedInUser != null && _userBox.containsKey(_loggedInUser)) {
      _isLoggedIn = true;
    } else {
      _isLoggedIn = false;
    }
    notifyListeners();
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> register(String username, String password, String fullName) async {
    if (_userBox.containsKey(username)) {
      return false; // Username sudah ada
    }
    final hashedPassword = _hashPassword(password);
    _userBox.put(username, {
      'passwordHash': hashedPassword,
      'fullName': fullName,
      'profilePic': null, // Nanti bisa dikembangkan untuk upload gambar
    });
    return true;
  }

  Future<bool> login(String username, String password) async {
    if (!_userBox.containsKey(username)) {
      return false;
    }

    final userData = _userBox.get(username);
    final storedHash = userData['passwordHash'];
    final inputHash = _hashPassword(password);

    if (storedHash == inputHash) {
      _isLoggedIn = true;
      _loggedInUser = username;
      _sessionBox.put('currentUser', username);
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isLoggedIn = false;
    _loggedInUser = null;
    _sessionBox.delete('currentUser');
    notifyListeners();
  }

  Map<dynamic, dynamic>? get currentUserData {
    if (_loggedInUser != null) {
      return _userBox.get(_loggedInUser);
    }
    return null;
  }
}