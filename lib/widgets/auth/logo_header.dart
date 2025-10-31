import 'package:flutter/material.dart';
import '../../theme.dart';

class LogoHeader extends StatelessWidget {
  final bool isLogin;
  final String titleLogin;
  final String titleRegister;
  final String subtitleLogin;
  final String subtitleRegister;
  final String imageUrl;

  const LogoHeader({
    super.key,
    required this.isLogin,
    required this.titleLogin,
    required this.titleRegister,
    required this.subtitleLogin,
    required this.subtitleRegister,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 260),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Image.network(
              imageUrl,
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
        Text(
          isLogin ? titleLogin : titleRegister,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppTheme.textColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          isLogin ? subtitleLogin : subtitleRegister,
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.textColor.withOpacity(0.75),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
