import 'package:flutter/material.dart';
import 'package:aliment/core/theme/app_colors.dart';

class EducationPage extends StatelessWidget {
  const EducationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      appBar: AppBar(
        backgroundColor: AppColors. normal,
        title: const Text(
          'Edukasi',
          style: TextStyle(
            fontFamily: 'Gabarito',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'Halaman Edukasi & Tips\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Gabarito',
            fontSize:  18,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}