import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:aliment/core/theme/app_colors.dart';
import 'package:aliment/features/services/share_service.dart';
import 'package:aliment/features/services/auth_service.dart';
import 'package:aliment/features/models/food_request_model.dart';
import 'package:aliment/features/models/shared_food_model.dart';

class ShareHistoryPage extends StatefulWidget {
  const ShareHistoryPage({super.key});

  @override
  State<ShareHistoryPage> createState() => _ShareHistoryPageState();
}

class _ShareHistoryPageState extends State<ShareHistoryPage>
    with SingleTickerProviderStateMixin {
  final ShareService _shareService = ShareService();
  final AuthService _authService = AuthService();
  late TabController _tabController;

  String?  _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadCurrentUser() {
    final user = _authService.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.light,
      appBar: AppBar(
        backgroundColor: AppColors.light,
        elevation: 0,
        leading:  IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darker),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Riwayat',
          style: TextStyle(
            fontFamily: 'Gabarito',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darker,
          ),
        ),
        centerTitle: true,
        bottom:  PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: _buildTabBar(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyRequestsHistory(),
          _buildMySharesHistory(),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.normal,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.darker,
        labelStyle: const TextStyle(
          fontFamily: 'Gabarito',
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Gabarito',
          fontWeight: FontWeight.normal,
          fontSize: 13,
        ),
        padding: const EdgeInsets.all(4),
        tabs: const [
          Tab(text: 'Permintaan Saya'),
          Tab(text: 'Yang Saya Bagikan'),
        ],
      ),
    );
  }

  // Tab 1: Riwayat permintaan saya ke orang lain
  Widget _buildMyRequestsHistory() {
    return StreamBuilder<List<FoodRequestModel>>(
      stream: _shareService.getMyRequests(_currentUserId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            ! snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final allRequests = snapshot.data ?? [];
        // Filter hanya yang sudah selesai (completed, rejected, cancelled)
        final historyRequests = allRequests
            .where((r) => r.isCompleted || r.isRejected || r.isCancelled)
            .toList();

        if (historyRequests.isEmpty) {
          return _buildEmptyState(
            icon: Icons.history,
            message: 'Belum ada riwayat permintaan',
            subMessage: 'Riwayat permintaan Anda akan muncul di sini',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: historyRequests.length,
          itemBuilder: (context, index) {
            return _buildRequestHistoryCard(historyRequests[index]);
          },
        );
      },
    );
  }

  // Tab 2: Riwayat makanan yang saya bagikan
  Widget _buildMySharesHistory() {
    return StreamBuilder<List<SharedFoodModel>>(
      stream: _shareService.getMySharedFoods(_currentUserId! ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final allShares = snapshot.data ?? [];
        // Filter hanya yang sudah selesai atau dibatalkan
        final historyShares = allShares
            .where((f) => f.isCompleted || f.isCancelled)
            .toList();

        if (historyShares.isEmpty) {
          return _buildEmptyState(
            icon: Icons. volunteer_activism_outlined,
            message: 'Belum ada riwayat berbagi',
            subMessage: 'Makanan yang sudah selesai dibagikan akan muncul di sini',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets. all(16),
          itemCount: historyShares.length,
          itemBuilder: (context, index) {
            return _buildShareHistoryCard(historyShares[index]);
          },
        );
      },
    );
  }

  Widget _buildRequestHistoryCard(FoodRequestModel request) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (request.status) {
      case 'completed':
        statusColor = Colors. green;
        statusText = 'Selesai';
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'Ditolak';
        statusIcon = Icons. cancel;
        break;
      case 'cancelled':
        statusColor = Colors.grey;
        statusText = 'Dibatalkan';
        statusIcon = Icons.block;
        break;
      default:
        statusColor = Colors. grey;
        statusText = request.status;
        statusIcon = Icons.info;
    }

    final dateText = request.completedAt != null
        ? DateFormat('dd MMM yyyy').format(request.completedAt!)
        : request.respondedAt != null
            ? DateFormat('dd MMM yyyy').format(request.respondedAt!)
            : DateFormat('dd MMM yyyy').format(request.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow:  [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: request.foodImageUrl != null &&
                    request.foodImageUrl!.isNotEmpty
                ?  Image.network(
                    request.foodImageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                  )
                : _buildPlaceholderImage(),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment. start,
              children: [
                Text(
                  request.foodName,
                  style: const TextStyle(
                    fontFamily: 'Gabarito',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'dari ${request.ownerName}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateText,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors. grey[500],
                  ),
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding:  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor. withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 14, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareHistoryCard(SharedFoodModel food) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (food.isCompleted) {
      statusColor = Colors.green;
      statusText = 'Selesai';
      statusIcon = Icons.check_circle;
    } else if (food. isCancelled) {
      statusColor = Colors.grey;
      statusText = 'Dibatalkan';
      statusIcon = Icons.block;
    } else {
      statusColor = Colors. grey;
      statusText = food.status;
      statusIcon = Icons.info;
    }

    final dateText = DateFormat('dd MMM yyyy').format(food.updatedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow:  [
          BoxShadow(
            color: Colors.black. withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: food.imageUrl != null && food.imageUrl!.isNotEmpty
                ? Image.network(
                    food.imageUrl! ,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                  )
                : _buildPlaceholderImage(),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  style: const TextStyle(
                    fontFamily: 'Gabarito',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${food.quantity} ${food.unit}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height:  4),
                Text(
                  dateText,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child:  Row(
              mainAxisSize:  MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 14, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight:  FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 60,
      height: 60,
      color: AppColors.light,
      child: Icon(Icons.fastfood, color: AppColors.normal),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String subMessage,
  }) {
    return Center(
      child:  Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontFamily: 'Gabarito',
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subMessage,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}