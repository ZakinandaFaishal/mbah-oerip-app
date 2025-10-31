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
  String _username = '';
  String _displayName = '';
  String? _phoneNumber = ''; // tambah penyimpanan no HP
  String? _profilePicPath;

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

  String? get profilePicPath => _profilePicPath;

  // Getter phoneNumber yang aman (non-nullable) membaca dari Hive
  String get phoneNumber =>
      (currentUserData?['phoneNumber'] as String?)?.trim() ?? '';

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

  // Panggil ini untuk update profil dari UI (tersimpan ke Hive)
  Future<void> updateProfile({
    String? displayName,
    String? phoneNumber,
    String? profilePicPath,
  }) async {
    if (_loggedInUser == null) return;
    final data = Map<String, dynamic>.from(currentUserData ?? {});
    if (displayName != null) data['fullName'] = displayName;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (profilePicPath != null) data['profilePic'] = profilePicPath;
    await _userBox.put(_loggedInUser, data);
    // sinkronkan cache lokal opsional
    if (displayName != null) _displayName = displayName;
    if (phoneNumber != null) _phoneNumber = phoneNumber;
    if (profilePicPath != null) _profilePicPath = profilePicPath;
    notifyListeners();
  }

  Future<bool> register(
    String username,
    String password,
    String fullName,
    String phoneNumber,
  ) async {
    if (_userBox.containsKey(username)) {
      return false; // Username sudah ada
    }
    final hashedPassword = _hashPassword(password);
    await _userBox.put(username, {
      'passwordHash': hashedPassword,
      'fullName': fullName,
      'profilePic': null,
      'phoneNumber': phoneNumber,
    });
    _username = username;
    _displayName = fullName;
    _phoneNumber = phoneNumber; // simpan no HP
    notifyListeners();
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
