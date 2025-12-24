import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aliment/core/theme/app_colors.dart';
import 'package:aliment/features/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve:  Curves.easeOutBack),
    );

    _controller.forward();

    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    
    if (! mounted) return;

    final authService = AuthService();
    final isLoggedIn = authService.currentUser != null;

    if (isLoggedIn) {
      context.go('/home');
    } else {
      context.go('/getStarted');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity:  _fadeAnimation,
              child:  ScaleTransition(
                scale:  _scaleAnimation,
                child: Column(
                  mainAxisAlignment:  MainAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/images/logo_aliment.png',
                      width: 150,
                      height: 150,
                    ),
                    const SizedBox(height: 24),
                    // App Name
                    const Text(
                      'Aliment',
                      style: TextStyle(
                        fontFamily: 'Gabarito',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darker,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Tagline
                    const Text(
                      'Kelola Makanan, Kurangi Limbah',
                      style: TextStyle(
                        fontFamily:  'Gabarito',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Loading indicator
                    const SizedBox(
                      width:  30,
                      height: 30,
                      child: CircularProgressIndicator(
                        color: AppColors.normal,
                        strokeWidth: 3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}