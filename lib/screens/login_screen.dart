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

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = false;

    try {
      if (_isLogin) {
        success = await authProvider.login(
          _usernameController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        success = await authProvider.register(
          _usernameController.text.trim(),
          _passwordController.text.trim(),
          _fullNameController.text.trim(),
          _phoneController.text.trim(),
        );
        if (success) {
          success = await authProvider.login(
            _usernameController.text.trim(),
            _passwordController.text.trim(),
          );
        }
      }

      if (success) {
        if (!mounted) return;
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
    final size = MediaQuery.of(context).size;
    const bg = Color(0xFFF2F3F5); // sama seperti Splash

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
                // Logo sederhana seperti Splash
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 260),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.restaurant_rounded,
                        size: 100,
                        color: AppTheme.primaryOrange,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Judul & subjudul ringkas
                Text(
                  _isLogin ? "Selamat Datang" : "Buat Akun Baru",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  _isLogin
                      ? "Nikmati pengalaman kuliner terbaik bersama kami"
                      : "Daftar untuk memulai pengalaman kuliner",
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textColor.withOpacity(0.75),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),

                // Form
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (!_isLogin) ...[
                          TextFormField(
                            controller: _fullNameController,
                            validator: (v) =>
                                v!.isEmpty ? 'Nama tidak boleh kosong' : null,
                            decoration: _buildInputDecoration(
                              "Nama Lengkap",
                              Icons.person_outline,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            validator: (v) {
                              final t = v?.trim() ?? '';
                              if (t.isEmpty)
                                return 'Nomor telepon tidak boleh kosong';
                              if (t.length < 9)
                                return 'Nomor telepon tidak valid';
                              return null;
                            },
                            decoration: _buildInputDecoration(
                              "Nomor Telepon",
                              Icons.phone_outlined,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextFormField(
                          controller: _usernameController,
                          validator: (v) =>
                              v!.isEmpty ? 'Username tidak boleh kosong' : null,
                          decoration: _buildInputDecoration(
                            "Username",
                            Icons.account_circle_outlined,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          validator: (v) => v!.length < 5
                              ? 'Password minimal 5 karakter'
                              : null,
                          decoration: _buildInputDecoration(
                            "Password",
                            Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppTheme.primaryOrange,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: _isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: AppTheme.primaryOrange,
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryOrange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    _isLogin ? "Login" : "Daftar",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                              _usernameController.clear();
                              _passwordController.clear();
                              _fullNameController.clear();
                              _phoneController.clear();
                            });
                          },
                          child: Text(
                            _isLogin
                                ? "Belum punya akun? Daftar sekarang"
                                : "Sudah punya akun? Login",
                            style: const TextStyle(
                              color: AppTheme.primaryOrange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String label,
    IconData icon, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppTheme.primaryOrange),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: Colors.grey),
      floatingLabelStyle: const TextStyle(
        color: AppTheme.primaryOrange,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
