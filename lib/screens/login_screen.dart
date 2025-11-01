import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'main_screen.dart';
import '../theme.dart';
import '../utils/password_hasher.dart';
import '../widgets/auth/logo_header.dart';
import '../widgets/auth/login_form.dart';
import '../widgets/auth/auth_toggle_text.dart';
// imports cleaned

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = false;

    try {
      final hashed = await PasswordHasher.hash(_passwordController.text.trim());

      if (_isLogin) {
        success = await authProvider.login(
          _usernameController.text.trim(),
          hashed,
        );
      } else {
        success = await authProvider.register(
          _usernameController.text.trim(),
          hashed,
          _fullNameController.text.trim(),
          _phoneController.text.trim(),
        );
        if (success) {
          success = await authProvider.login(
            _usernameController.text.trim(),
            hashed,
          );
        }
      }

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else {
        _showErrorDialog(
          _isLogin ? 'Login Gagal' : 'Registrasi Gagal',
          _isLogin
              ? 'Username atau password salah.'
              : 'Username mungkin sudah digunakan.',
        );
      }
    } catch (_) {
      _showErrorDialog('Terjadi Kesalahan', 'Tidak dapat terhubung ke server.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                  imageUrl:
                      'https://monitoringweb.decoratics.id/images/mbah-oerip/1761922682.png',
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
                      _usernameController.clear();
                      _passwordController.clear();
                      _fullNameController.clear();
                      _phoneController.clear();
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
