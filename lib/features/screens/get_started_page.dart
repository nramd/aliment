import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aliment/core/theme/app_colors.dart';

class GetStarted extends StatelessWidget {
  const GetStarted({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/get_started_img.png', 
                height: 300,
              ),
              const SizedBox(height: 40),
              const Text(
                'Kelola Makanan,\nKurangi Limbah',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Gabarito',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darker,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Jaga kesegaran makananmu dan bantu selamatkan lingkungan dengan Aliment.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Gabarito',
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.push('/loginPage'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkActive,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Mulai Sekarang',
                    style: TextStyle(
                      fontFamily: 'Gabarito',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}