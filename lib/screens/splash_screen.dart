import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'main_screen.dart';
import '../theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goNext();
  }

  Future<void> _goNext() async {
    // jeda singkat agar logo terlihat
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            auth.isLoggedIn ? const MainScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // background abu muda seperti contoh
    const bg = Color(0xFFF2F3F5);

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              // fallback jika asset belum tersedia
              errorBuilder: (_, __, ___) => Icon(
                Icons.restaurant_rounded,
                size: 120,
                color: AppTheme.primaryOrange,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
