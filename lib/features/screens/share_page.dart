import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aliment/core/theme/app_colors.dart';
import 'package:aliment/features/services/auth_service.dart';
import 'package:aliment/features/services/food_service.dart';
import 'package:aliment/features/models/food_item_model.dart';
import 'package:aliment/features/screens/share_explore_tab.dart';
import 'package:aliment/features/screens/share_my_shares_tab.dart';

class SharePage extends StatefulWidget {
  const SharePage({super. key});

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final FoodService _foodService = FoodService();
  late TabController _tabController;
  
  Stream<List<FoodItemModel>>? _foodStream;
  String _displayName = 'User';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = _authService. currentUser;
    if (user != null) {
      // Initialize food stream for notifications
      setState(() {
        _foodStream = _foodService.getFoodItems(user.uid);
      });
      
      final userData = await _authService.getUserData(user.uid);
      if (userData != null && mounted) {
        setState(() {
          _displayName = userData.displayName;
        });
      } else if (user.displayName != null &&
          user.displayName! .isNotEmpty &&
          mounted) {
        setState(() {
          _displayName = user.displayName!;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.light,
      body: SafeArea(
        child:  Column(
          children: [
            // Header
            _buildHeader(),

            // Tab Bar
            _buildTabBar(),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  ShareExploreTab(userId: user.uid),
                  ShareMySharesTab(userId: user.uid, userName: _displayName),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.normal,
            child: Text(
              _displayName.isNotEmpty ? _displayName[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Colors. white,
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
                    fontWeight:  FontWeight.bold,
                    color: AppColors.normal,
                  ),
                ),
                const Text(
                  'Bagikan makananmu, kurangi limbah! ',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.darker,
                  ),
                ),
              ],
            ),
          ),
          _buildIconButton(Icons.history, () {
            context.push('/shareHistory');
          }),
          _buildNotificationButton(),
        ],
      ),
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
    // Jika stream belum ready, tampilkan icon biasa
    if (_foodStream == null) {
      return InkWell(
        onTap: () => context.push('/notifications'),
        borderRadius: BorderRadius.circular(8),
        child: const Padding(
          padding: EdgeInsets.all(6.0),
          child: Icon(
            Icons.notifications_outlined,
            color: AppColors.darker,
            size: 28,
          ),
        ),
      );
    }

    return StreamBuilder<List<FoodItemModel>>(
      stream: _foodStream,
      builder: (context, snapshot) {
        final foods = snapshot.data ?? [];
        final expiringCount = foods
            . where((f) => f.daysUntilExpiry <= 3 && f.daysUntilExpiry >= 0)
            .length;
        final expiredCount = foods.where((f) => f.daysUntilExpiry < 0).length;
        final totalAlerts = expiringCount + expiredCount;

        return InkWell(
          onTap:  () => context.push('/notifications'),
          borderRadius: BorderRadius. circular(8),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Stack(
              children: [
                Icon(
                  totalAlerts > 0
                      ? Icons. notifications_active
                      : Icons.notifications_outlined,
                  color: totalAlerts > 0 ? Colors.orange : AppColors.darker,
                  size: 28,
                ),
                if (totalAlerts > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets. all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        totalAlerts > 9 ?  '9+' : '$totalAlerts',
                        style: const TextStyle(
                          color:  Colors.white,
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

  Widget _buildTabBar() {
    return Container(
      margin:  const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color:  Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller:  _tabController,
        indicator:  BoxDecoration(
          color:  AppColors.normal,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize. tab,
        dividerColor:  Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.darker,
        labelStyle: const TextStyle(
          fontFamily: 'Gabarito',
          fontWeight: FontWeight. bold,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Gabarito',
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
        padding: const EdgeInsets.all(4),
        tabs: const [
          Tab(text: 'Jelajahi'),
          Tab(text: 'Bagikan'),
        ],
      ),
    );
  }
}