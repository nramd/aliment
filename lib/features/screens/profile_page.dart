import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aliment/core/theme/app_colors.dart';
import 'package:aliment/features/services/auth_service.dart';
import 'package:aliment/features/services/food_service.dart';
import 'package:aliment/features/models/food_item_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super. key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final FoodService _foodService = FoodService();

  String _displayName = 'User';
  String _email = '';
  Stream<List<FoodItemModel>>? _foodStream;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      // Initialize food stream
      setState(() {
        _foodStream = _foodService.getFoodItems(user.uid);
      });

      final userData = await _authService.getUserData(user.uid);
      if (userData != null && mounted) {
        setState(() {
          _displayName = userData.displayName;
          _email = userData. email;
        });
      } else if (mounted) {
        setState(() {
          _displayName = user.displayName ?? 'User';
          _email = user.email ?? '';
        });
      }
    }
  }

  Future<void> _signOut() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Keluar',
          style: TextStyle(fontFamily: 'Gabarito'),
        ),
        content: const Text('Apakah Anda yakin ingin keluar? '),
        actions: [
          TextButton(
            onPressed:  () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: TextStyle(color: Colors. grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _authService. signOut();
              if (mounted) {
                context.go('/loginPage');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Keluar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors. light,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment. start,
            children: [
              const SizedBox(height:  8),

              // Title
              const Text(
                'Profil',
                style: TextStyle(
                  fontFamily:  'Gabarito',
                  fontSize: 24,
                  fontWeight: FontWeight. bold,
                  color: AppColors.darker,
                ),
              ),

              const SizedBox(height: 24),

              // Profile Card
              Container(
                padding: const EdgeInsets. all(20),
                decoration:  BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color:  Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius:  35,
                      backgroundColor:  AppColors.normal,
                      child: Text(
                        _displayName.isNotEmpty
                            ? _displayName[0]. toUpperCase()
                            :  'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _displayName,
                            style: const TextStyle(
                              fontFamily: 'Gabarito',
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _email,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Food Summary Card - Now using StreamBuilder
              _buildFoodSummarySection(),

              const SizedBox(height: 24),

              // Menu Items
              const Text(
                'Pengaturan',
                style: TextStyle(
                  fontFamily: 'Gabarito',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),

              _buildMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Notifikasi',
                subtitle: 'Atur pengingat kadaluarsa',
                onTap: () => context.push('/notificationSettings'),
              ),

              _buildMenuItem(
                icon: Icons.person_outline,
                title: 'Edit Profil',
                subtitle: 'Ubah nama dan foto profil',
                onTap:  () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur coming soon')),
                  );
                },
              ),

              _buildMenuItem(
                icon: Icons.help_outline,
                title: 'Bantuan',
                subtitle:  'FAQ dan panduan penggunaan',
                onTap:  () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur coming soon')),
                  );
                },
              ),

              _buildMenuItem(
                icon: Icons.info_outline,
                title: 'Tentang Aplikasi',
                subtitle: 'Versi 1.0.0',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Aliment',
                    applicationVersion:  '1.0.0',
                    applicationLegalese: '© 2025 Aliment',
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'Aliment adalah aplikasi untuk mengelola bahan makanan dan mengurangi food waste.',
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _signOut,
                  icon:  const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Keluar',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color:  Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height:  40),
            ],
          ),
        ),
      ),
    );
  }

  // Realtime Food Summary menggunakan StreamBuilder
  Widget _buildFoodSummarySection() {
    if (_foodStream == null) {
      return const SizedBox. shrink();
    }

    return StreamBuilder<List<FoodItemModel>>(
      stream:  _foodStream,
      builder:  (context, snapshot) {
        // Hitung statistik dari data realtime
        final foods = snapshot.data ?? [];
        final total = foods.length;
        final expired = foods.where((f) => f.daysUntilExpiry < 0).length;
        final expiringSoon = foods
            .where((f) => f.daysUntilExpiry >= 0 && f.daysUntilExpiry <= 3)
            .length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Makanan',
              style: TextStyle(
                fontFamily: 'Gabarito',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height:  12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    '$total',
                    'Total',
                    AppColors.normal,
                  ),
                  _buildSummaryItem(
                    '$expired',
                    'Kadaluarsa',
                    Colors.red,
                  ),
                  _buildSummaryItem(
                    '$expiringSoon',
                    'Segera',
                    Colors.orange,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Gabarito',
            fontWeight: FontWeight. bold,
            fontSize: 24,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding:  const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors. normal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.normal),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Gabarito',
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style:  TextStyle(
            fontSize: 12,
            color: Colors. grey[600],
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey[400],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}