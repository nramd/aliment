import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:aliment/core/theme/app_colors.dart';
import 'package:aliment/features/services/food_service.dart';
import 'package:aliment/features/models/food_item_model.dart';

class FoodDetailPage extends StatefulWidget {
  final String foodId;

  const FoodDetailPage({
    super.key,
    required this.foodId,
  });

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  final FoodService _foodService = FoodService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      body: SafeArea(
        child: StreamBuilder<FoodItemModel?>(
          stream: _foodService.getFoodById(widget.foodId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child:  CircularProgressIndicator());
            }

            if (snapshot.hasError || ! snapshot.hasData || snapshot.data == null) {
              return Center(
                child: Column(
                  mainAxisAlignment:  MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text('Makanan tidak ditemukan'),
                    const SizedBox(height:  16),
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Kembali'),
                    ),
                  ],
                ),
              );
            }

            final food = snapshot.data!;
            return _buildContent(food);
          },
        ),
      ),
    );
  }

  Widget _buildContent(FoodItemModel food) {
    final formattedAddedDate = DateFormat('dd MMMM yyyy').format(food.addedDate);
    final formattedExpiryDate = DateFormat('dd MMMM yyyy').format(food.expiryDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets. all(16.0),
          child: Row(
            children:  [
              InkWell(
                onTap: () => context.pop(),
                child: Row(
                  children: [
                    Icon(Icons.chevron_left, color: AppColors.darker),
                    const Text(
                      'Kembali',
                      style: TextStyle(
                        fontFamily:  'Gabarito',
                        color: AppColors.darker,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:  [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Etalase Bahan Makanan',
                    style: TextStyle(
                      fontFamily: 'Gabarito',
                      fontSize: 22,
                      fontWeight:  FontWeight.bold,
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
              InkWell(
                onTap: () => context.push('/addFood'),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration:  BoxDecoration(
                    color: AppColors.normal,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Detail Card
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow:  [
                  BoxShadow(
                    color: Colors. black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child:  Column(
                crossAxisAlignment:  CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Detail Makanan',
                        style:  TextStyle(
                          fontFamily: 'Gabarito',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          // Delete button
                          InkWell(
                            onTap: () => _showDeleteDialog(food),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius. circular(6),
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Edit button
                          OutlinedButton.icon(
                            onPressed: () => context.push('/editFood/${food.id}'),
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Edit'),
                            style:  OutlinedButton.styleFrom(
                              foregroundColor: AppColors.normal,
                              side: BorderSide(color: AppColors.normal),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Food Preview Header
                  Row(
                    children: [
                      // Image
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: AppColors.light,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: food.imageUrl != null && food.imageUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius:  BorderRadius.circular(8),
                                child: Image.network(
                                  food.imageUrl!,
                                  fit:  BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      _getCategoryIcon(food.category),
                                      color: AppColors.normal,
                                      size: 35,
                                    );
                                  },
                                ),
                              )
                            : Icon(
                                _getCategoryIcon(food.category),
                                color: AppColors. normal,
                                size: 35,
                              ),
                      ),
                      const SizedBox(width: 16),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment:  CrossAxisAlignment.start,
                          children: [
                            Text(
                              food.name,
                              style: const TextStyle(
                                fontFamily: 'Gabarito',
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${food.quantity}${food.unit} • ${food. category}',
                              style:  TextStyle(
                                color:  Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(food.daysUntilExpiry).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                food.expiryStatus,
                                style: TextStyle(
                                  fontSize:  12,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(food.daysUntilExpiry),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Detail Info
                  _buildDetailRow('Nama Makanan', food.name),
                  _buildDetailRow('Berat/Jumlah', '${food.quantity}${food.unit}'),
                  _buildDetailRow('Kategori', food.category),
                  _buildDetailRow('Tanggal Ditambahkan', formattedAddedDate),
                  _buildDetailRow('Kadaluarsa Dalam', '${food.daysUntilExpiry} Hari'),
                  _buildDetailRow('Tanggal Kadaluarsa', formattedExpiryDate),

                  const SizedBox(height: 24),

                  // Bagikan Button
                  SizedBox(
                    width:  double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fitur Bagikan Coming Soon'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.normal,
                        shape: RoundedRectangleBorder(
                          borderRadius:  BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Bagikan',
                        style: TextStyle(
                          fontFamily: 'Gabarito',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height:  16),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors. grey[600],
              fontSize:  14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Gabarito',
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(int daysUntilExpiry) {
    if (daysUntilExpiry < 0) return Colors.red;
    if (daysUntilExpiry <= 3) return Colors.orange;
    return Colors.green;
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
              context.pop();
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