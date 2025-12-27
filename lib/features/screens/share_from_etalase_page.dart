import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aliment/core/theme/app_colors.dart';
import 'package:aliment/features/services/auth_service.dart';
import 'package:aliment/features/services/food_service.dart';
import 'package:aliment/features/models/food_item_model.dart';

class ShareFromEtalasePage extends StatefulWidget {
  const ShareFromEtalasePage({super.key});

  @override
  State<ShareFromEtalasePage> createState() => _ShareFromEtalasePageState();
}

class _ShareFromEtalasePageState extends State<ShareFromEtalasePage> {
  final AuthService _authService = AuthService();
  final FoodService _foodService = FoodService();

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
      appBar: AppBar(
        backgroundColor: AppColors. light,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darker),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Pilih dari Etalase',
          style: TextStyle(
            fontFamily: 'Gabarito',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darker,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Card
          _buildInfoCard(),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Pilih makanan yang ingin dibagikan',
              style: TextStyle(
                fontFamily: 'Gabarito',
                fontSize: 16,
                fontWeight: FontWeight. bold,
                color: AppColors. darker,
              ),
            ),
          ),

          // Food List
          Expanded(
            child: StreamBuilder<List<FoodItemModel>>(
              stream: _foodService.getFoodItems(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    ! snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot. hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final allFoods = snapshot.data ?? [];
                // Filter makanan yang belum di-share dan belum expired
                final availableFoods = allFoods
                    .where((f) => !f.isShared && f. daysUntilExpiry >= 0)
                    .toList();

                if (availableFoods.isEmpty) {
                  return _buildEmptyState(allFoods. isEmpty);
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: availableFoods.length,
                  itemBuilder: (context, index) {
                    return _buildFoodCard(availableFoods[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.normal. withOpacity(0.1),
        borderRadius: BorderRadius. circular(12),
        border: Border.all(color: AppColors.normal. withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.normal, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child:  Text(
              'Pilih makanan dari etalase Anda untuk dibagikan ke orang lain di sekitar.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.darker,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isEtalaseEmpty) {
    return Center(
      child:  Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isEtalaseEmpty ? Icons.inventory_2_outlined : Icons.check_circle_outline,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              isEtalaseEmpty
                  ? 'Etalase Anda kosong'
                  : 'Semua makanan sudah dibagikan',
              style: const TextStyle(
                fontFamily: 'Gabarito',
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isEtalaseEmpty
                  ?  'Tambahkan makanan ke etalase terlebih dahulu'
                  : 'Tambahkan makanan baru ke etalase untuk dibagikan',
              style:  TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (isEtalaseEmpty)
              ElevatedButton. icon(
                onPressed: () => context.push('/addFood'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah Makanan'),
                style:  ElevatedButton.styleFrom(
                  backgroundColor: AppColors.normal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodCard(FoodItemModel food) {
    final Color statusColor = food. daysUntilExpiry <= 3
        ? Colors.orange
        : AppColors.normal;

    final String expiryText = food.daysUntilExpiry == 0
        ? 'Hari Ini'
        : '${food.daysUntilExpiry} hari lagi';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:  Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.push('/setShareLocation', extra: food),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Food Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: food.imageUrl != null && food.imageUrl!.isNotEmpty
                    ? Image.network(
                        food.imageUrl!,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage(food.category);
                        },
                      )
                    : _buildPlaceholderImage(food.category),
              ),
              const SizedBox(width: 12),

              // Food Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: const TextStyle(
                        fontFamily: 'Gabarito',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.normal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            food.category,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.normal,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${food.quantity} ${food.unit}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size:  14,
                          color: statusColor,
                        ),
                        const SizedBox(width:  4),
                        Text(
                          'Exp: $expiryText',
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.normal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: AppColors.normal,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(String category) {
    return Container(
      width: 70,
      height:  70,
      color: AppColors.light,
      child: Icon(
        _getCategoryIcon(category),
        color: AppColors.normal,
        size: 32,
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category. toLowerCase()) {
      case 'protein':
        return Icons.kebab_dining;
      case 'sayuran':
        return Icons. eco;
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
      case 'roti':
        return Icons.bakery_dining;
      case 'frozen':
        return Icons.ac_unit;
      default:
        return Icons.fastfood;
    }
  }
}