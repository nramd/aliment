import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aliment/core/theme/app_colors.dart';
import 'package:aliment/features/services/auth_service.dart';
import 'package:aliment/features/services/food_service.dart';
import 'package:aliment/features/models/food_item_model.dart';
import 'package:aliment/features/services/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.onSwitchToTab});

  final Function(int)? onSwitchToTab;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  final AuthService _authService = AuthService();
  final FoodService _foodService = FoodService();

  String _displayName = 'User';
  late Stream<List<FoodItemModel>> _foodStream;

  @override
  bool get wantKeepAlive => true; // Mencegah rebuild saat switch tab

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initFoodStream();
    _checkAndScheduleNotifications();
  }

  Future<void> _checkAndScheduleNotifications() async {
    final user = _authService.currentUser;
    if (user != null) {
      await NotificationService().checkAndScheduleExpiryNotifications(user.uid);
    }
  }

  void _initFoodStream() {
    final user = _authService.currentUser;
    if (user != null) {
      _foodStream = _foodService.getFoodItems(user.uid);
    }
  }

  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      final userData = await _authService.getUserData(user.uid);
      if (userData != null && mounted) {
        setState(() {
          _displayName = userData.displayName;
        });
      } else if (user.displayName != null &&
          user.displayName!.isNotEmpty &&
          mounted) {
        setState(() {
          _displayName = user.displayName!;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final user = _authService.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.light,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(), // Mengurangi bounce effect
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildEtalaseSection(user.uid),
                const SizedBox(height: 24),
                _buildJelajahiSection(),
                const SizedBox(height: 24),
                _buildEdukasiSection(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: AppColors.normal,
          child: Text(
            _displayName.isNotEmpty ? _displayName[0].toUpperCase() : 'U',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, $_displayName',
                style: const TextStyle(
                  fontFamily: 'Gabarito',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.normal,
                ),
              ),
              const Text(
                'Kelola dan Bagikan Makananmu Hari ini! ',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.darker,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            _buildIconButton(Icons.history, () {
              context.push('/shareHistory');
            }),
            _buildNotificationButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, color: AppColors.darker, size: 24),
      ),
    );
  }

  Widget _buildNotificationButton() {
    return StreamBuilder<List<FoodItemModel>>(
      stream: _foodStream,
      builder: (context, snapshot) {
        final foods = snapshot.data ?? [];
        final expiringCount = foods
            .where((f) => f.daysUntilExpiry <= 3 && f.daysUntilExpiry >= 0)
            .length;
        final expiredCount = foods.where((f) => f.daysUntilExpiry < 0).length;
        final totalAlerts = expiringCount + expiredCount;

        return InkWell(
          onTap: () => context.push('/notifications'),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Stack(
              children: [
                Icon(
                  totalAlerts > 0
                      ? Icons.notifications_active
                      : Icons.notifications_outlined,
                  color: totalAlerts > 0 ? Colors.orange : AppColors.darker,
                  size: 28,
                ),
                if (totalAlerts > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                      child: Text(
                        totalAlerts > 9 ? '9+' : '$totalAlerts',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEtalaseSection(String userId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Etalase Bahan Makanan',
          style: TextStyle(
            fontFamily: 'Gabarito',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darker,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.normal,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: StreamBuilder<List<FoodItemModel>>(
            stream: _foodStream,
            builder: (context, snapshot) {
              // Tampilkan loading hanya saat pertama kali
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const SizedBox(
                  height: 150,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return SizedBox(
                  height: 150,
                  child: Center(child: Text('Error: ${snapshot.error}')),
                );
              }

              final foods = snapshot.data ?? [];
              final displayFoods = foods.take(2).toList();

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (displayFoods.isEmpty)
                    const SizedBox(
                      height: 80,
                      child: Center(
                        child: Text(
                          'Belum ada bahan makanan',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ...displayFoods.map((food) => _buildFoodItem(food)),
                  _buildAddFoodButton(),
                  const SizedBox(height: 12),
                  _buildLihatSemuaButton(foods.length),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFoodItem(FoodItemModel food) {
    final Color statusColor =
        food.daysUntilExpiry <= 3 ? Colors.red : AppColors.normal;
    final String expiryText = food.daysUntilExpiry < 0
        ? 'Kadaluarsa'
        : food.daysUntilExpiry == 0
            ? 'Hari Ini'
            : '${food.daysUntilExpiry} Hari';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.normal.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Food Image dengan ukuran tetap untuk mencegah layout shift
          SizedBox(
            width: 50,
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: food.imageUrl != null && food.imageUrl!.isNotEmpty
                    ? Image.network(
                        food.imageUrl!,
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50,
                        // Placeholder saat loading
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.normal,
                              ),
                            ),
                          );
                        },
                        // Error handler
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            _getCategoryIcon(food.category),
                            color: AppColors.normal,
                            size: 28,
                          );
                        },
                      )
                    : Icon(
                        _getCategoryIcon(food.category),
                        color: AppColors.normal,
                        size: 28,
                      ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  style: const TextStyle(
                    fontFamily: 'Gabarito',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${food.quantity}${food.unit}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'Segera Olah Dalam:  ',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      expiryText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddFoodButton() {
    return InkWell(
      onTap: () => context.push('/addFood'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.light,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.normal.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.normal,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Text(
              'Tambahkan Bahan Makanan',
              style: TextStyle(
                fontFamily: 'Gabarito',
                fontWeight: FontWeight.w500,
                color: AppColors.darker,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLihatSemuaButton(int totalItems) {
    return Center(
      child: ElevatedButton(
        onPressed: () => context.push('/etalase'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkActive,
          // Tambahkan padding horizontal (kiri-kanan) agar tombol tidak terlalu sempit
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Lihat Semua ($totalItems)',
          style: const TextStyle(
            fontFamily: 'Gabarito',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildJelajahiSection() {
    final List<Map<String, String>> nearbyFoods = [
      {'name': 'Pisang Ambon', 'distance': '0.06 Km', 'image': 'banana'},
      {'name': 'Jus Alpukat', 'distance': '0.11 Km', 'image': 'avocado'},
      {'name': 'Omelette Telur', 'distance': '0.17 Km', 'image': 'egg'},
      {'name': 'Nasi Goreng', 'distance': '0.26 Km', 'image': 'rice'},
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Jelajahi makanan di sekitarmu',
              style: TextStyle(
                fontFamily: 'Gabarito',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darker,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Lihat Semua',
                style: TextStyle(
                  color: AppColors.normal,
                  decoration: TextDecoration.underline,
                  fontFamily: 'Gabarito',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(4, 4),
              ),
            ],
          ),
          child: SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              itemCount: nearbyFoods.length,
              itemBuilder: (context, index) {
                final food = nearbyFoods[index];
                return _buildNearbyFoodCard(
                  food['name']!,
                  food['distance']!,
                  food['image']!,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNearbyFoodCard(String name, String distance, String imageKey) {
    IconData icon;
    Color bgColor;

    switch (imageKey) {
      case 'banana':
        icon = Icons.eco;
        bgColor = Colors.yellow.shade100;
        break;
      case 'avocado':
        icon = Icons.local_drink;
        bgColor = Colors.green.shade100;
        break;
      case 'egg':
        icon = Icons.egg;
        bgColor = Colors.orange.shade100;
        break;
      case 'rice':
        icon = Icons.rice_bowl;
        bgColor = Colors.brown.shade100;
        break;
      default:
        icon = Icons.fastfood;
        bgColor = Colors.grey.shade100;
    }

    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Icon(icon, size: 50, color: AppColors.normal),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Gabarito',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 2),
                    Text(
                      distance,
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEdukasiSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.normal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edukasi & Tips',
                  style: TextStyle(
                    fontFamily: 'Gabarito',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.light,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pelajari cara mengurangi limbah makanan dengan tips dan resep praktis',
                  style: TextStyle(fontSize: 12, color: AppColors.light),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    widget.onSwitchToTab?.call(2);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.light,
                    foregroundColor: AppColors.normal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Lihat Selengkapnya',
                    style: TextStyle(
                      fontFamily: 'Gabarito',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.menu_book, size: 40, color: AppColors.normal),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'daging':
      case 'protein':
        return Icons.kebab_dining;
      case 'sayuran':
        return Icons.eco;
      case 'buah':
        return Icons.apple;
      case 'minuman':
        return Icons.local_drink;
      case 'makanan kaleng':
        return Icons.inventory_2;
      case 'dairy':
        return Icons.egg;
      case 'bumbu':
        return Icons.spa;
      default:
        return Icons.fastfood;
    }
  }
}
