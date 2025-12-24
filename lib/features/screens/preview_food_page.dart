import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:aliment/core/theme/app_colors.dart';
import 'package:aliment/features/services/food_service.dart';
import 'package:aliment/features/services/storage_service.dart';
import 'package:aliment/features/services/auth_service.dart';
import 'package:aliment/features/models/food_item_model.dart';

class PreviewFoodPage extends StatefulWidget {
  final FoodItemModel food;
  final File? imageFile;

  const PreviewFoodPage({
    super.key,
    required this. food,
    this.imageFile,
  });

  @override
  State<PreviewFoodPage> createState() => _PreviewFoodPageState();
}

class _PreviewFoodPageState extends State<PreviewFoodPage> {
  final FoodService _foodService = FoodService();
  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  String _loadingMessage = '';

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/addFood');
    }
  }

  Future<void> _saveFood() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Menyimpan data... ';
    });

    try {
      String? imageUrl;

      // Upload gambar jika ada
      if (widget.imageFile != null) {
        setState(() {
          _loadingMessage = 'Mengupload gambar...';
        });

        final user = _authService.currentUser;
        if (user != null) {
          imageUrl = await _storageService. uploadFoodImage(
            imageFile: widget.imageFile!,
            userId: user.uid,
          );
        }
      }

      setState(() {
        _loadingMessage = 'Menyimpan ke database...';
      });

      // Buat food item dengan imageUrl
      final foodWithImage = widget.food.copyWith(imageUrl: imageUrl);

      await _foodService.addFoodItem(foodWithImage);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bahan makanan berhasil ditambahkan! '),
            backgroundColor: Colors.green,
          ),
        );
        
        // Gunakan pushReplacement untuk menghindari glitch
        // Kembali ke home dan clear stack
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:  Text('Gagal menyimpan:  $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMessage = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;
    final formattedAddedDate = DateFormat('dd MMMM yyyy').format(food.addedDate);
    final formattedExpiryDate = DateFormat('dd MMMM yyyy').format(food.expiryDate);

    return Scaffold(
      backgroundColor: AppColors.light,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: _isLoading ? null : _handleBack,
                        child: Row(
                          children: [
                            Icon(
                              Icons.chevron_left,
                              color: _isLoading ? Colors.grey : AppColors.darker,
                            ),
                            Text(
                              'Kembali',
                              style: TextStyle(
                                fontFamily: 'Gabarito',
                                color: _isLoading ? Colors. grey : AppColors.darker,
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
                  child: Column(
                    crossAxisAlignment:  CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Preview Makanan',
                        style: TextStyle(
                          fontFamily: 'Gabarito',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.normal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pastikan kembali informasi yang anda input telah sesuai',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Preview Card
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Card
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Detail Makanan',
                                style: TextStyle(
                                  fontFamily: 'Gabarito',
                                  fontSize:  16,
                                  fontWeight:  FontWeight.bold,
                                ),
                              ),
                              OutlinedButton. icon(
                                onPressed:  _isLoading ? null : _handleBack,
                                icon: const Icon(Icons.edit, size: 16),
                                label: const Text('Edit'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.normal,
                                  side: BorderSide(color: AppColors. normal),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                ),
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
                                  borderRadius:  BorderRadius.circular(8),
                                ),
                                child: widget.imageFile != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child:  Image.file(
                                          widget.imageFile!,
                                          fit: BoxFit. cover,
                                        ),
                                      )
                                    : Icon(
                                        Icons.fastfood,
                                        color: AppColors.normal,
                                        size: 35,
                                      ),
                              ),
                              const SizedBox(width: 16),
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
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${food.quantity} ${food.unit} • ${food.category}',
                                      style:  TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Status Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration:  BoxDecoration(
                                        color: food. daysUntilExpiry <= 3
                                            ? Colors.orange. withOpacity(0.2)
                                            : Colors. green.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        food.expiryStatus,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: food.daysUntilExpiry <= 3
                                              ?  Colors.orange
                                              :  Colors.green,
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
                          _buildDetailRow('Berat/Jumlah', '${food.quantity} ${food.unit}'),
                          _buildDetailRow('Kategori', food.category),
                          _buildDetailRow('Tanggal Ditambahkan', formattedAddedDate),
                          _buildDetailRow('Kadaluarsa Dalam', '${food.daysUntilExpiry} Hari'),
                          _buildDetailRow('Tanggal Kadaluarsa', formattedExpiryDate),
                          if (widget.imageFile != null)
                            _buildDetailRow('Gambar', 'Terlampir ✓'),

                          const SizedBox(height: 24),

                          // Simpan Button
                          SizedBox(
                            width: double. infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveFood,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.normal,
                                disabledBackgroundColor: AppColors.normal.withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child:  CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Simpan ke Etalase',
                                      style: TextStyle(
                                        fontFamily: 'Gabarito',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors. white,
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
            ),

            // Loading Overlay
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: AppColors.normal,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _loadingMessage,
                          style: const TextStyle(
                            fontFamily: 'Gabarito',
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:  [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Gabarito',
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}