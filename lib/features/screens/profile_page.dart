import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aliment/core/theme/app_colors.dart';
import 'package:aliment/features/services/auth_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.light,
      body: SafeArea(
        child:  Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Avatar
              CircleAvatar(
                radius:  60,
                backgroundColor: AppColors. normal,
                child: Text(
                  user?.displayName?. substring(0, 1).toUpperCase() ?? 'U',
                  style:  const TextStyle(
                    fontSize: 48,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Name
              Text(
                user?.displayName ??  'User',
                style:  const TextStyle(
                  fontFamily: 'Gabarito',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darker,
                ),
              ),
              const SizedBox(height: 8),
              // Email
              Text(
                user?.email ?? '',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height:  40),
              
              // Menu Items
              _buildMenuItem(
                icon: Icons.person_outline,
                title: 'Edit Profil',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur Coming Soon')),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Notifikasi',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur Coming Soon')),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons. help_outline,
                title: 'Bantuan',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur Coming Soon')),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.info_outline,
                title: 'Tentang Aplikasi',
                onTap:  () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Aliment v1.0.0')),
                  );
                },
              ),
              
              const Spacer(),
              
              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child:  ElevatedButton. icon(
                  onPressed: () async {
                    // Show confirmation dialog
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Apakah Anda yakin ingin keluar? '),
                        actions: [
                          TextButton(
                            onPressed:  () => Navigator.pop(context, false),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Logout',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (shouldLogout == true && context.mounted) {
                      await authService.signOut();
                      if (context.mounted) {
                        context.go('/getStarted');
                      }
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      fontFamily: 'Gabarito',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.normal),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily:  'Gabarito',
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius:  BorderRadius.circular(12),
        ),
      ),
    );
  }
}