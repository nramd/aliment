import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aliment/core/theme/app_colors.dart';
import 'package:aliment/features/services/share_service.dart';
import 'package:aliment/features/models/shared_food_model.dart';
import 'package:aliment/features/models/food_request_model.dart';

class ShareMySharesTab extends StatefulWidget {
  final String userId;
  final String userName;

  const ShareMySharesTab({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<ShareMySharesTab> createState() => _ShareMySharesTabState();
}

class _ShareMySharesTabState extends State<ShareMySharesTab> {
  final ShareService _shareService = ShareService();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tombol Bagikan Makanan
          _buildShareButton(),

          const SizedBox(height: 16),

          _buildStatsSection(),

          const SizedBox(height: 24),

          // Makanan yang Saya Bagikan
          _buildMySharedFoodsSection(),

          const SizedBox(height: 24),

          // Permintaan Saya
          _buildMyRequestsSection(),

          const SizedBox(height: 16),

          // Link ke Riwayat
          _buildHistoryLink(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildShareButton() {
    return InkWell(
      onTap: () => context.push('/shareFromEtalase'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.normal, AppColors.darkActive],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.normal.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.volunteer_activism,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bagikan Makanan',
                    style: TextStyle(
                      fontFamily: 'Gabarito',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pilih dari etalase & tentukan lokasi',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return StreamBuilder<List<SharedFoodModel>>(
      stream: _shareService.getMySharedFoods(widget.userId),
      builder: (context, snapshot) {
        final foods = snapshot.data ?? [];

        final activeCount =
            foods.where((f) => f.isAvailable || f.isReserved).length;
        final completedCount = foods.where((f) => f.isCompleted).length;
        final totalRequests =
            foods.fold<int>(0, (sum, f) => sum + f.requestCount);

        return Container(
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              _buildStatItem(
                icon: Icons.inventory_2_outlined,
                value: '$activeCount',
                label: 'Aktif',
                color: AppColors.normal,
              ),
              _buildStatDivider(),
              _buildStatItem(
                icon: Icons.check_circle_outline,
                value: '$completedCount',
                label: 'Selesai',
                color: Colors.green,
              ),
              _buildStatDivider(),
              _buildStatItem(
                icon: Icons.people_outline,
                value: '$totalRequests',
                label: 'Request',
                color: Colors.orange,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Gabarito',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[200],
    );
  }

  Widget _buildMySharedFoodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Makanan yang Saya Bagikan',
          style: TextStyle(
            fontFamily: 'Gabarito',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darker,
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<SharedFoodModel>>(
          stream: _shareService.getMySharedFoods(widget.userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final foods = snapshot.data ?? [];
            final activeFoods =
                foods.where((f) => f.isAvailable || f.isReserved).toList();

            if (activeFoods.isEmpty) {
              return _buildEmptyCard(
                icon: Icons.inventory_2_outlined,
                message: 'Belum ada makanan yang dibagikan',
                subMessage: 'Klik tombol di atas untuk mulai berbagi',
              );
            }

            return Column(
              children: activeFoods
                  .map((food) => _buildMySharedFoodCard(food))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMySharedFoodCard(SharedFoodModel food) {
    final statusColor = food.isReserved ? Colors.blue : AppColors.normal;
    final statusText = food.isReserved ? 'Direservasi' : 'Tersedia';

    return InkWell(
      onTap: () => context.push('/sharedFood/${food.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: food.imageUrl != null && food.imageUrl!.isNotEmpty
                      ? Image.network(
                          food.imageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 60,
                            height: 60,
                            color: AppColors.light,
                            child:
                                Icon(Icons.fastfood, color: AppColors.normal),
                          ),
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          color: AppColors.light,
                          child: Icon(Icons.fastfood, color: AppColors.normal),
                        ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              food.name,
                              style: const TextStyle(
                                fontFamily: 'Gabarito',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 10,
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${food.quantity} ${food.unit} • Exp: ${food.daysUntilExpiry} hari',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.people_outline,
                              size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            '${food.requestCount} permintaan',
                            style: TextStyle(
                              fontSize: 12,
                              color: food.requestCount > 0
                                  ? AppColors.normal
                                  : Colors.grey[500],
                              fontWeight: food.requestCount > 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (food.requestCount > 0 && food.isAvailable) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/requestQueue/${food.id}'),
                  icon: const Icon(Icons.list_alt, size: 18),
                  label: const Text('Lihat Antrian'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.normal,
                    side: BorderSide(color: AppColors.normal),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
            if (food.isReserved) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _confirmMarkAsCompleted(food),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Tandai Sudah Diambil'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.normal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmMarkAsCompleted(SharedFoodModel food) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
            const Text('Konfirmasi', style: TextStyle(fontFamily: 'Gabarito')),
        content: Text('Tandai "${food.name}" sebagai sudah diambil?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (food.selectedRequestId != null) {
                await _shareService.markAsCompleted(
                  food.selectedRequestId!,
                  food.id,
                  food.foodId,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Berhasil ditandai selesai! '),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.normal),
            child: const Text('Ya, Selesai',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildMyRequestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Permintaan Saya',
          style: TextStyle(
            fontFamily: 'Gabarito',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darker,
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<FoodRequestModel>>(
          stream: _shareService.getMyRequests(widget.userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final requests = snapshot.data ?? [];
            final activeRequests =
                requests.where((r) => r.isPending || r.isAccepted).toList();

            if (activeRequests.isEmpty) {
              return _buildEmptyCard(
                icon: Icons.inbox_outlined,
                message: 'Belum ada permintaan aktif',
                subMessage: 'Jelajahi makanan di tab sebelah',
              );
            }

            return Column(
              children: activeRequests
                  .take(3)
                  .map((req) => _buildRequestCard(req))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRequestCard(FoodRequestModel request) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (request.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Menunggu';
        statusIcon = Icons.hourglass_empty;
        break;
      case 'accepted':
        statusColor = Colors.green;
        statusText = 'Diterima';
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = Colors.grey;
        statusText = request.status;
        statusIcon = Icons.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        boxShadow: [
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
            child:
                request.foodImageUrl != null && request.foodImageUrl!.isNotEmpty
                    ? Image.network(
                        request.foodImageUrl!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 50,
                          height: 50,
                          color: AppColors.light,
                          child: Icon(Icons.fastfood, color: AppColors.normal),
                        ),
                      )
                    : Container(
                        width: 50,
                        height: 50,
                        color: AppColors.light,
                        child: Icon(Icons.fastfood, color: AppColors.normal),
                      ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Row(
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (request.isPending) ...[
                      const SizedBox(width: 8),
                      Text(
                        '• Antrian #${request.queuePosition}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Actions
          if (request.isPending)
            IconButton(
              onPressed: () => _confirmCancelRequest(request),
              icon: Icon(Icons.close, color: Colors.red[300], size: 20),
              tooltip: 'Batalkan',
            ),

          if (request.isAccepted)
            IconButton(
              onPressed: () =>
                  context.push('/sharedFood/${request.sharedFoodId}'),
              icon: Icon(Icons.location_on, color: AppColors.normal, size: 20),
              tooltip: 'Lihat Lokasi',
            ),
        ],
      ),
    );
  }

  void _confirmCancelRequest(FoodRequestModel request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Batalkan Permintaan',
            style: TextStyle(fontFamily: 'Gabarito')),
        content: Text('Batalkan permintaan untuk "${request.foodName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tidak', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _shareService.cancelRequest(
                  request.id, request.sharedFoodId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Permintaan dibatalkan'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ya, Batalkan',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryLink() {
    return InkWell(
      onTap: () => context.push('/shareHistory'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.history, color: AppColors.normal),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Lihat Riwayat',
                style: TextStyle(
                  fontFamily: 'Gabarito',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard({
    required IconData icon,
    required String message,
    required String subMessage,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'Gabarito',
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subMessage,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}
