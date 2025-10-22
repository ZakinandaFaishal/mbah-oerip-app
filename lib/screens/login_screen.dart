import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController(); // Untuk register
  bool _isLogin = true; // Untuk toggle antara login dan register
  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() { _isLoading = true; });

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
          // Setelah register berhasil, langsung login
          success = await authProvider.login(
            _usernameController.text,
            _passwordController.text,
          );
        }
      }

      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => MainScreen()),
        );
      } else {
        _showErrorDialog(_isLogin ? 'Login Gagal' : 'Registrasi Gagal',
                         _isLogin ? 'Username atau password salah.' : 'Username mungkin sudah digunakan.');
      }
    } catch (e) {
      _showErrorDialog('Terjadi Kesalahan', 'Tidak dapat terhubung ke server.');
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.restaurant_menu, size: 80, color: Colors.brown),
                const SizedBox(height: 20),
                Text(
                  _isLogin ? 'Selamat Datang Kembali' : 'Buat Akun Baru',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                if (!_isLogin)
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Nama tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Username tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 5) {
                      return 'Password minimal 5 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(_isLogin ? 'LOGIN' : 'REGISTER'),
                  ),
                TextButton(
                  child: Text(
                    _isLogin
                        ? 'Belum punya akun? Register'
                        : 'Sudah punya akun? Login',
                  ),
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}