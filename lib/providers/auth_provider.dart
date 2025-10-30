import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AuthProvider extends ChangeNotifier {
  // Box sudah dibuka di main.dart
  final Box _userBox = Hive.box('users');
  final Box _sessionBox = Hive.box('session');

  bool _isLoggedIn = false;
  String? _loggedInUser;

  bool get isLoggedIn => _isLoggedIn;
  String get username => _loggedInUser ?? '';

  Map<String, dynamic>? get currentUserData {
    if (_loggedInUser == null) return null;
    final raw = _userBox.get(_loggedInUser);
    if (raw is Map) return Map<String, dynamic>.from(raw as Map);
    return null;
  }

  String get displayName =>
      currentUserData?['fullName']?.toString().trim().isNotEmpty == true
      ? currentUserData!['fullName'] as String
      : username;

  String? get profilePicPath => currentUserData?['profilePic'] as String?;

  AuthProvider() {
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    _loggedInUser = _sessionBox.get('currentUser') as String?;
    _isLoggedIn = _loggedInUser != null;
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

  // Tambahkan helper untuk update foto profil
  Future<void> updateProfilePic(String? filePath) async {
    if (_loggedInUser == null) return;
    final data = Map<String, dynamic>.from(currentUserData ?? {});
    data['profilePic'] = filePath; // boleh null untuk hapus foto
    await _userBox.put(_loggedInUser, data);
    notifyListeners();
  }
}
