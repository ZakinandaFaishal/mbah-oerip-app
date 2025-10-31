import 'package:flutter/material.dart';
import '../../theme.dart';

class AuthToggleText extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onToggle;
  const AuthToggleText({
    super.key,
    required this.isLogin,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onToggle,
      child: Text(
        isLogin
            ? "Belum punya akun? Daftar sekarang"
            : "Sudah punya akun? Login",
        style: const TextStyle(
          color: AppTheme.primaryOrange,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
