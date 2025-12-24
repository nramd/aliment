import 'dart:async';
import 'package:aliment/core/navigation/app_router.dart';
import 'package:aliment/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:aliment/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const Aliment());
}

class Aliment extends StatelessWidget {
  const Aliment({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'Aliment',
      theme: AppTheme.lightTheme,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      context.go('/getStarted');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              'assets/images/logo_aliment.png',
              width: 200,
              height: 200,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Aliment',
            style: TextStyle(
              fontFamily: 'Gabarito',
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: AppColors.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class GetStarted extends StatelessWidget {
  const GetStarted({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/get_started_img.png',
              width: 300,
              height: 300,
            ),
            Text(
              'Bingung Mengelola\nSisa Makanan ?',
              style: TextStyle(
                fontSize: 25,
                fontFamily: 'Gabarito',
                fontWeight: FontWeight.w600,
                color: AppColors.dark,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Aliment hadir untuk memudahkan\nkalian dalam mengelola',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Gabarito',
                fontWeight: FontWeight.normal,
                color: AppColors.darker,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/loginPage');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkActive,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Mulai Sekarang',
                    style: TextStyle(
                      fontFamily: 'Gabarito',
                      fontSize: 16,
                      color: AppColors.light,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
