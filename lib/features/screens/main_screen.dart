import 'package:flutter/material.dart';
import 'package:aliment/core/theme/app_colors.dart';
import 'package:aliment/features/screens/home_page.dart';
import 'package:aliment/features/screens/share_page.dart';
import 'package:aliment/features/screens/education_page.dart';
import 'package:aliment/features/screens/profile_page.dart';
import 'package:aliment/features/screens/share_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    HomePage(
      onSwitchToTab: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
    ),
    const SharePage(),
    const EducationPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.normal,
          selectedItemColor: AppColors.darker,
          unselectedItemColor: AppColors.white,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Gabarito',
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Gabarito',
          ),
          iconSize: 28,
          selectedFontSize: 14,
          unselectedFontSize: 14,
          items: [
            _buildNavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Beranda',
            ),
            _buildNavItem(
              icon: Icons.favorite_outline,
              activeIcon: Icons.volunteer_activism,
              label: 'Berbagi',
            ),
            _buildNavItem(
              icon: Icons.menu_book_outlined,
              activeIcon: Icons.menu_book,
              label: 'Edukasi',
            ),
            _buildNavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    const double verticalOffset = 8.0;

    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(top: verticalOffset),
        child: Icon(icon),
      ),
      activeIcon: Padding(
        padding: const EdgeInsets.only(top: verticalOffset),
        child: Icon(activeIcon),
      ),
      label: label,
    );
  }
}
