import 'package:flutter/material.dart';
import '../../theme.dart';

class FABHomeButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isActive;

  const FABHomeButton({
    super.key,
    required this.onPressed,
    required this.isActive,
  });

  @override
  State<FABHomeButton> createState() => _FABHomeButtonState();
}

class _FABHomeButtonState extends State<FABHomeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.8,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut)),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            _controller.forward(from: 0.0);
            widget.onPressed();
          },
          backgroundColor: AppTheme.primaryOrange,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.home, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}
