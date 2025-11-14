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
    // jalankan setelah frame pertama agar context siap
    WidgetsBinding.instance.addPostFrameCallback((_) => _goNext());
  }

  Future<void> _goNext() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              auth.isLoggedIn ? const MainScreen() : const LoginScreen(),
        ),
      );
    } catch (_) {
      // fallback ke login agar tidak “stuck”
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
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
