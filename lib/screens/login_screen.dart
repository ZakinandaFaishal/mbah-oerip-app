import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'main_screen.dart';
import '../theme.dart';
import '../widgets/auth/logo_header.dart';
import '../widgets/auth/login_form.dart';
import '../widgets/auth/auth_toggle_text.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/phone_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(); // RENAMED
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String? error;

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (_isLogin) {
        // Login normal
        error = await authProvider.login(email, password);
        if (error == null && mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
          return;
        }
      } else {
        // Registrasi: JANGAN auto-login ketika email confirmation aktif.
        // Tampilkan dialog agar user memverifikasi email terlebih dahulu.
        final normalizedPhone = PhoneUtils.normalizeID(
          _phoneController.text.trim(),
        );
        error = await authProvider.register(
          email,
          password,
          _fullNameController.text.trim(),
          normalizedPhone,
          _usernameController.text.trim(),
        );

        if (error == null) {
          // Sukses mendaftar, arahkan user untuk verifikasi email-nya.
          if (mounted) {
            await _showVerifyDialog(email);
          }
          return;
        }
      }

      // Jika ada error dari proses di atas
      if (error != null) {
        // Tangani pesan khusus: Email not confirmed
        if (!_isLogin && error.toLowerCase().contains('email')) {
          await _showVerifyDialog(_emailController.text.trim());
        } else if (_isLogin &&
            error.toLowerCase().contains('email not confirmed')) {
          await _showVerifyDialog(_emailController.text.trim());
        } else {
          _showErrorDialog(
            _isLogin ? 'Login Gagal' : 'Registrasi Gagal',
            error,
          );
        }
      }
    } catch (e) {
      _showErrorDialog('Terjadi Kesalahan', 'Tidak dapat terhubung ke server.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showVerifyDialog(String email) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Verifikasi Email Diperlukan'),
        content: Text(
          'Kami telah mengirimkan tautan verifikasi ke $email.\n\n'
          'Silakan buka email Anda lalu klik tautan verifikasi. Setelah itu, kembali ke aplikasi dan coba login lagi.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Coba buka aplikasi email atau Gmail web
              final mailto = Uri.parse('mailto:$email');
              final gmail = Uri.parse('https://mail.google.com/');
              if (await canLaunchUrl(mailto)) {
                await launchUrl(mailto);
              } else {
                await launchUrl(gmail, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text(
              'Buka Email',
              style: TextStyle(color: AppTheme.primaryOrange),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              // Setelah user mengonfirmasi dari email, coba login lagi
              setState(() => _isLoading = true);
              final error =
                  await Provider.of<AuthProvider>(context, listen: false).login(
                    _emailController.text.trim(),
                    _passwordController.text.trim(),
                  );
              setState(() => _isLoading = false);
              if (error == null && mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const MainScreen()),
                );
              } else if (error != null) {
                _showErrorDialog('Login Gagal', error);
              }
            },
            child: const Text(
              'Saya Sudah Verifikasi',
              style: TextStyle(color: AppTheme.primaryOrange),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text(
              'OK',
              style: TextStyle(color: AppTheme.primaryOrange),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF2F3F5);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: size.width < 500 ? size.width : 420,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                LogoHeader(
                  isLogin: _isLogin,
                  titleLogin: 'Selamat Datang',
                  titleRegister: 'Buat Akun Baru',
                  subtitleLogin:
                      'Nikmati pengalaman kuliner terbaik bersama kami',
                  subtitleRegister: 'Daftar untuk memulai pengalaman kuliner',
                  // Gambar dari URL (bukan asset)
                  imageUrl: 'assets/images/logo.png',
                ),
                const SizedBox(height: 22),

                LoginForm(
                  formKey: _formKey,
                  isLogin: _isLogin,
                  isLoading: _isLoading,
                  obscurePassword: _obscurePassword,
                  onToggleObscure: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  fullNameController: _fullNameController,
                  phoneController: _phoneController,
                  emailController: _emailController,
                  usernameController: _usernameController,
                  passwordController: _passwordController,
                  onSubmit: _submit,
                ),
                const SizedBox(height: 8),
                // Continue as guest (browsing only, cannot checkout)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      final auth = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      await auth.signInAsGuest();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const MainScreen()),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.primaryOrange),
                      foregroundColor: AppTheme.primaryOrange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Lanjutkan sebagai Tamu'),
                  ),
                ),

                const SizedBox(height: 8),
                AuthToggleText(
                  isLogin: _isLogin,
                  onToggle: () {
                    setState(() {
                      _isLogin = !_isLogin;
                      _emailController.clear();
                      _passwordController.clear();
                      _fullNameController.clear();
                      _phoneController.clear();
                      _usernameController.clear();
                    });
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
