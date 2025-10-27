import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'main_screen.dart';
import '../theme.dart';

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
  bool _isLogin = true;
  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = false;

    try {
      if (_isLogin) {
        success = await authProvider.login(
          _usernameController.text,
          _passwordController.text,
        );
      } else {
        success = await authProvider.register(
          _usernameController.text,
          _passwordController.text,
          _fullNameController.text,
        );
        if (success) {
          success = await authProvider.login(
            _usernameController.text,
            _passwordController.text,
          );
        }
      }

      if (success) {
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
            child: const Text('OK',
                style: TextStyle(color: AppTheme.primaryRed)),
            onPressed: () => Navigator.of(ctx).pop(),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: size.width < 500 ? size.width : 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.restaurant_menu, size: 90, color: AppTheme.primaryRed),
                const SizedBox(height: 20),

                Text(
                  _isLogin ? "Masuk" : "Buat Akun Baru",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isLogin
                      ? "Silakan login untuk melanjutkan"
                      : "Isi data berikut dengan benar",
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (!_isLogin)
                        TextFormField(
                          controller: _fullNameController,
                          validator: (v) =>
                              v!.isEmpty ? 'Nama tidak boleh kosong' : null,
                          decoration:
                              _buildField("Nama Lengkap", Icons.person_outline),
                        ),
                      if (!_isLogin) const SizedBox(height: 14),

                      TextFormField(
                        controller: _usernameController,
                        validator: (v) =>
                            v!.isEmpty ? 'Username tidak boleh kosong' : null,
                        decoration: _buildField("Username", Icons.person),
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        validator: (v) => v!.length < 5
                            ? 'Password minimal 5 karakter'
                            : null,
                        decoration: _buildField("Password", Icons.lock),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: AppTheme.primaryRed))
                            : ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryRed,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(
                                  _isLogin ? "Login" : "Daftar",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                      ),
                      const SizedBox(height: 14),

                      TextButton(
                        onPressed: () =>
                            setState(() => _isLogin = !_isLogin),
                        child: Text(
                          _isLogin
                              ? "Belum punya akun? Daftar sekarang"
                              : "Sudah punya akun? Login",
                          style: const TextStyle(
                              color: AppTheme.primaryRed,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildField(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppTheme.primaryRed),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppTheme.primaryRed, width: 2),
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}
