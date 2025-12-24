import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aliment/core/theme/app_colors.dart';
import 'package:aliment/features/services/auth_service.dart';
import 'package:aliment/features/services/food_service.dart';
import 'package:aliment/features/models/food_item_model.dart';

class EtalasePage extends StatefulWidget {
  const EtalasePage({super.key});

  @override
  State<EtalasePage> createState() => _EtalasePageState();
}

class _EtalasePageState extends State<EtalasePage> {
  final AuthService _authService = AuthService();
  final FoodService _foodService = FoodService();

  void _handleBack() {
    // Cek apakah bisa pop, jika tidak maka go ke home
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.light,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan Back Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: _handleBack, // Gunakan function yang sudah di-handle
                    child: Row(
                      children: [
                        Icon(Icons.chevron_left, color: AppColors.darker),
                        const Text(
                          'Kembali',
                          style: TextStyle(
                            fontFamily: 'Gabarito',
                            color: AppColors.darker,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Title Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:  [
                  Column(
                    crossAxisAlignment:  CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Etalase Bahan Makanan',
                        style: TextStyle(
                          fontFamily: 'Gabarito',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.normal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kelola semua bahan makananmu',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  // Tombol Tambah
                  InkWell(
                    onTap: () => context.push('/addFood'),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.normal,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Food List
            Expanded(
              child: StreamBuilder<List<FoodItemModel>>(
                stream: _foodService.getFoodItems(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: AppColors.normal),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  if (! snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment:  MainAxisAlignment.center,
                        children: [
                          Icon(Icons.kitchen_outlined, size: 80, color: Colors.grey[300]),
                          const SizedBox(height: 10),
                          Text(
                            "Belum ada makanan tersimpan",
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton. icon(
                            onPressed:  () => context.push('/addFood'),
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text(
                              'Tambah Makanan',
                              style:  TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final foods = snapshot.data!;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: foods. length,
                    itemBuilder:  (context, index) {
                      final food = foods[index];
                      return _buildFoodCard(food);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodCard(FoodItemModel food) {
    final Color statusColor = food. daysUntilExpiry <= 3 ? Colors.red : AppColors.normal;
    final String expiryText = food.daysUntilExpiry < 0
        ? 'Kadaluarsa'
        :  food.daysUntilExpiry == 0
            ? 'Hari Ini'
            : '${food.daysUntilExpiry} Hari';

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
          // Food Image/Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.light,
              borderRadius: BorderRadius.circular(8),
            ),
            child: food.imageUrl != null && food.imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      food.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          _getCategoryIcon(food.category),
                          color: AppColors.normal,
                          size: 30,
                        );
                      },
                    ),
                  )
                : Icon(
                    _getCategoryIcon(food.category),
                    color: AppColors.normal,
                    size: 30,
                  ),
          ),
          const SizedBox(width:  12),

          // Food Info
          Expanded(
            child: InkWell(
              onTap: () => context.push('/foodDetail/${food.id}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontFamily:  'Gabarito',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${food.quantity}${food.unit}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Segera Olah Dalam:  ',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        expiryText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Action Buttons
          Column(
            children: [
              // Edit Button
              InkWell(
                onTap: () => context.push('/editFood/${food.id}'),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.normal. withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.edit_outlined, color: AppColors.normal, size: 20),
                ),
              ),
              const SizedBox(height: 8),
              // Delete Button
              InkWell(
                onTap: () => _showDeleteDialog(food),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red. withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(FoodItemModel food) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Makanan'),
        content: Text('Apakah Anda yakin ingin menghapus "${food.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              _foodService.deleteFoodItem(food.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${food.name} berhasil dihapus'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category. toLowerCase()) {
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