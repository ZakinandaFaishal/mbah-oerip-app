import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Dapatkan client Supabase global dari main.dart
final supabase = Supabase.instance.client;

class AuthProvider extends ChangeNotifier {
  bool _isGuest = false;

  // Sumber kebenaran (source of truth) kita sekarang adalah Supabase User
  User? get _currentUser => supabase.auth.currentUser;

  // --- GETTERS (Mirip seperti yang Anda punya) ---
  bool get isLoggedIn => _currentUser != null;
  bool get isGuest => _isGuest;

  // Email resmi dari auth
  String get email => _currentUser?.email ?? '';

  // Username disimpan di metadata (bukan email)
  String get username =>
      (currentUserData?['username'] as String?)?.trim() ?? '';

  // Data user (full_name, dll) disimpan di 'user_metadata' Supabase
  Map<String, dynamic>? get currentUserData {
    if (_currentUser == null) return null;
    return _currentUser!.userMetadata;
  }

  // Getter 'displayName' membaca dari metadata
  String get displayName =>
      currentUserData?['full_name']?.toString().trim().isNotEmpty == true
      ? currentUserData!['full_name'] as String
      : (username.isNotEmpty ? username : email);

  // Getter 'profilePicPath' membaca dari metadata
  String? get profilePicPath => currentUserData?['profilePic'];

  // Getter 'phoneNumber' membaca dari metadata
  String get phoneNumber =>
      (currentUserData?['phoneNumber'] as String?)?.trim() ?? '';

  String? _profilePicUrl;
  String? get profilePicUrl => _profilePicUrl;

  // --- KONSTRUKTOR ---
  AuthProvider() {
    _checkLoginStatus(); // Cek status awal saat app dibuka

    // INI BAGIAN PENTING:
    // Dengarkan perubahan status auth dari Supabase (login, logout)
    supabase.auth.onAuthStateChange.listen((data) {
      _checkLoginStatus();
      notifyListeners(); // Beri tahu UI bahwa ada perubahan
    });
  }

  // --- FUNGSI INTERNAL ---
  void _checkLoginStatus() {
    // Jika user sudah login di Supabase, pastikan mode Guest mati
    if (isLoggedIn) {
      _isGuest = false;
    }
  }

  // --- METODE/FUNGSI (Logika diubah ke Supabase) ---

  Future<void> signInAsGuest() async {
    // Jika user login (di Supabase), logout dulu
    if (isLoggedIn) {
      await supabase.auth.signOut();
    }
    _isGuest = true; // tidak disimpan lokal lagi
    notifyListeners();
  }

  Future<String?> updateProfile({
    String? displayName,
    String? phoneNumber,
    String? username,
    String? profilePicPath,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return 'Belum login';

    String? publicUrl;
    try {
      if (profilePicPath != null && profilePicPath.isNotEmpty) {
        final file = File(profilePicPath);
        final ext = file.path.split('.').last.toLowerCase();
        final storagePath = 'users/${user.id}/avatar.$ext';
        await Supabase.instance.client.storage
            .from('avatars')
            .upload(
              storagePath,
              file,
              fileOptions: const FileOptions(upsert: true),
            );
        publicUrl = Supabase.instance.client.storage
            .from('avatars')
            .getPublicUrl(storagePath);
      }

      // Note: Do NOT set the 'phone' attribute here, as it triggers SMS verification
      // and fails when no SMS provider is configured. Store in metadata only.
      final attrs = UserAttributes(
        data: {
          if (displayName != null) 'full_name': displayName,
          if (username != null) 'username': username,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
          if (publicUrl != null) 'profilePic': publicUrl,
        },
      );

      await Supabase.instance.client.auth.updateUser(attrs);
      _profilePicUrl = publicUrl ?? _profilePicUrl;
      notifyListeners();
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Gagal memperbarui profil';
    }
  }

  // Convenience wrapper if UI only wants to update the avatar
  Future<String?> updateProfilePic(String? filePath) async {
    return updateProfile(profilePicPath: filePath);
  }

  // Utility: check if the 'avatars' bucket exists (useful for diagnostics)
  Future<bool> avatarsBucketExists() async {
    final buckets = await supabase.storage.listBuckets();
    return buckets.any((b) => b.id == 'avatars');
  }

  // Fungsi Register (diubah dari username ke email)
  Future<String?> register(
    String email, // <-- PENTING: Supabase menggunakan email
    String password,
    String fullName,
    String phoneNumber,
    String username,
  ) async {
    try {
      final redirect = 'ingkung-mbah-oerip://login-callback';
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'username': username,
          'phoneNumber': phoneNumber,
        },
        emailRedirectTo: redirect, // penting: override localhost
      );

      if (response.user == null) {
        return "Registrasi gagal, user tidak dibuat.";
      }
      // Beberapa versi Supabase Flutter kadang belum melampirkan metadata penuh
      // setelah signUp. Paksa update ulang metadata (tanpa set kolom auth.phone
      // agar tidak memicu SMS provider yang belum dikonfigurasi).
      try {
        await supabase.auth.updateUser(
          UserAttributes(
            data: {
              'full_name': fullName,
              'phoneNumber': phoneNumber,
              'username': username,
              'profilePic': null,
            },
          ),
        );
      } catch (e) {
        debugPrint('Fallback update metadata/phone gagal: $e');
      }

      // Opsional: simpan ke tabel profiles untuk jaga unik username (abaikan error jika tabel belum ada)
      try {
        await supabase.from('profiles').upsert({
          'user_id': response.user!.id,
          'username': username,
          'full_name': fullName,
          'phone_number': phoneNumber,
          'profile_pic': null,
        });
      } catch (e) {
        debugPrint('Insert profiles diabaikan: $e');
      }
      // 'onAuthStateChange' akan menangani sisanya
      return null; // Sukses, tidak ada error
    } catch (e) {
      debugPrint("Error register: $e");
      return e.toString(); // Kembalikan pesan error
    }
  }

  // Fungsi Login (diubah dari username ke email)
  Future<String?> login(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return "Login gagal, data user tidak ditemukan.";
      }
      // 'onAuthStateChange' akan menangani sisanya
      return null; // Sukses, tidak ada error
    } catch (e) {
      debugPrint("Error login: $e");
      return e.toString(); // Kembalikan pesan error
    }
  }

  // Fungsi Logout
  Future<void> logout() async {
    _isGuest = false; // reset flag guest di memori
    await supabase.auth.signOut();
    // 'onAuthStateChange' akan menangani sisanya
  }
}
