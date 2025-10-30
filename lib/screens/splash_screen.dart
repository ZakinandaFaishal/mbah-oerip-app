import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'main_screen.dart';
import 'dart:math' as math;
import '../theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _loadingController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _animateSequence();

    // Panggil navigasi setelah frame pertama selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginAndNavigate();
    });
  }

  Future<void> _animateSequence() async {
    await _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginAndNavigate() async {
    // Beri jeda agar animasi splash screen terlihat
    await Future.delayed(const Duration(seconds: 4));

    if (!mounted) return; // Pastikan widget masih ada di tree

    // Baca status login dari provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Lakukan navigasi berdasarkan status login
    if (authProvider.isLoggedIn) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _loadingController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryOrange,
                      AppTheme.primaryOrange.withOpacity(0.85),
                      Colors.orange.shade600,
                    ],
                    transform: GradientRotation(
                      _loadingController.value * 6.28,
                    ),
                  ),
                ),
              );
            },
          ),

          // Decorative elements
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),

          // Main content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with scale animation
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        height: 280,
                        width: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.restaurant_rounded,
                                  size: 120,
                                  color: AppTheme.primaryOrange,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),

                    // App name with slide animation
                    SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          Text(
                            'Meal Monkey',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 12),

                          Text(
                            'Cita Rasa Tradisional yang Lezat',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              fontStyle: FontStyle.italic,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Advanced loading animation
                    _buildAdvancedLoadingIndicator(),

                    const SizedBox(height: 30),

                    // Loading text
                    _buildLoadingText(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedLoadingIndicator() {
    return AnimatedBuilder(
      animation: _loadingController,
      builder: (context, child) {
        return SizedBox(
          height: 80,
          width: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: _loadingController.value * 6.28,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                ),
              ),

              Transform.rotate(
                angle: -_loadingController.value * 3.14,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                ),
              ),

              CustomPaint(
                size: const Size(80, 80),
                painter: _AdvancedLoadingPainter(
                  progress: _loadingController.value,
                  color: Colors.white,
                ),
              ),

              Transform.scale(
                scale:
                    0.6 +
                    (0.4 *
                        (0.5 +
                            0.5 * math.sin(_loadingController.value * 12.56))),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingText() {
    return AnimatedBuilder(
      animation: _loadingController,
      builder: (context, child) {
        int dots = (((_loadingController.value * 4).toInt()) % 4);
        String loadingText = 'Memuat' + ('.' * dots);

        return Text(
          loadingText,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        );
      },
    );
  }
}

class _AdvancedLoadingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _AdvancedLoadingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      3.14159 * (0.5 + 0.5 * math.sin(progress * 12.56)),
      false,
      paint,
    );

    final accentPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10),
      progress * 6.28,
      3.14159 / 4,
      false,
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(_AdvancedLoadingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
