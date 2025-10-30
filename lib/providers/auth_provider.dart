import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AuthProvider extends ChangeNotifier {
  // Box sudah dibuka di main.dart, jadi ini aman
  final Box _userBox = Hive.box('users');
  final Box _sessionBox = Hive.box('session');

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  String? _loggedInUser;
  String? get loggedInUser => _loggedInUser;

  // Konstruktor akan langsung memeriksa status login saat provider dibuat
  AuthProvider() {
    _checkLoginStatus();
  }

  // Metode ini memeriksa sesi yang tersimpan
  void _checkLoginStatus() {
    _loggedInUser = _sessionBox.get('currentUser');
    if (_loggedInUser != null && _userBox.containsKey(_loggedInUser)) {
      _isLoggedIn = true;
    } else {
      _isLoggedIn = false;
    }
    // Tidak perlu notifyListeners() di sini karena ini terjadi di konstruktor
    // sebelum widget lain mendengarkan.
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> register(
    String username,
    String password,
    String fullName,
  ) async {
    if (_userBox.containsKey(username)) {
      return false; // Username sudah ada
    }
    final hashedPassword = _hashPassword(password);
    await _userBox.put(username, {
      'passwordHash': hashedPassword,
      'fullName': fullName,
      'profilePic': null,
    });
    return true;
  }

  Future<bool> login(String username, String password) async {
    if (!_userBox.containsKey(username)) {
      return false; // User tidak ditemukan
    }

    final userData = _userBox.get(username);
    final storedHash = userData['passwordHash'];
    final inputHash = _hashPassword(password);

    if (storedHash == inputHash) {
      _isLoggedIn = true;
      _loggedInUser = username;
      await _sessionBox.put('currentUser', username); // Simpan sesi
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await _sessionBox.clear(); // Hapus sesi
    _isLoggedIn = false;
    _loggedInUser = null;
    notifyListeners();
  }

  Map<dynamic, dynamic>? get currentUserData {
    if (_loggedInUser != null) {
      return _userBox.get(_loggedInUser);
    }
    return null;
  }
}
