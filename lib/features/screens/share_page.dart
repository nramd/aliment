import 'package:flutter/material.dart';
import 'package:aliment/core/theme/app_colors.dart';

class SharePage extends StatelessWidget {
  const SharePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      appBar: AppBar(
        backgroundColor: AppColors.normal,
        title: const Text(
          'Berbagi Makanan',
          style: TextStyle(
            fontFamily: 'Gabarito',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'Halaman Berbagi Makanan\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Gabarito',
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}