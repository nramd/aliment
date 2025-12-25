import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:aliment/core/theme/app_colors.dart';
import 'package:aliment/features/services/auth_service.dart';
import 'package:aliment/features/services/food_service.dart';
import 'package:aliment/features/models/food_item_model.dart';
import 'package:aliment/features/models/food_suggestion_model.dart';

class NotificationListPage extends StatefulWidget {
  const NotificationListPage({super.key});

  @override
  State<NotificationListPage> createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  final AuthService _authService = AuthService();
  final FoodService _foodService = FoodService();

  void _handleBack() {
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
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: _handleBack,
                    child: const Icon(Icons.chevron_left, color: AppColors.darker, size: 28),
                  ),
                  const Expanded(
                    child: Text(
                      'Notification',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Gabarito',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darker,
                      ),
                    ),
                  ),
                  const SizedBox(width: 28), // Balance the back button
                ],
              ),
            ),

            // Notification List
            Expanded(
              child: StreamBuilder<List<FoodItemModel>>(
                stream:  _foodService.getFoodItems(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && ! snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot. hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final allFoods = snapshot.data ?? [];
                  
                  // Filter makanan yang perlu diperhatikan (7 hari atau kurang)
                  final notificationFoods = allFoods
                      .where((food) => food. daysUntilExpiry <= 7)
                      .toList()
                    ..sort((a, b) => a.daysUntilExpiry.compareTo(b.daysUntilExpiry));

                  if (notificationFoods.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: notificationFoods.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(notificationFoods[index]);
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada notifikasi',
            style: TextStyle(
              fontFamily: 'Gabarito',
              fontSize: 18,
              fontWeight: FontWeight. bold,
              color: Colors. grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Semua makanan Anda masih aman! ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(FoodItemModel food) {
    final suggestion = FoodSuggestion.getSuggestion(food.name, food.category);
    
    String expiryText;
    Color borderColor;
    
    if (food.daysUntilExpiry < 0) {
      expiryText = 'sudah kadaluarsa ${-food.daysUntilExpiry} hari lalu! ';
      borderColor = Colors. red;
    } else if (food.daysUntilExpiry == 0) {
      expiryText = 'akan kadaluarsa hari ini!';
      borderColor = Colors.red;
    } else if (food.daysUntilExpiry == 1) {
      expiryText = 'akan kadaluarsa besok!';
      borderColor = Colors.orange;
    } else {
      expiryText = 'akan kadaluarsa dalam ${food.daysUntilExpiry} hari!';
      borderColor = food.daysUntilExpiry <= 3 ? Colors.orange : AppColors.normal;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor. withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:  () => _showDetailBottomSheet(food, suggestion),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Food Icon/Image
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.light,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius:  BorderRadius.circular(8),
                    child: food.imageUrl != null && food.imageUrl!.isNotEmpty
                        ? Image.network(
                            food.imageUrl!,
                            fit: BoxFit.cover,
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
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text:  TextSpan(
                          style: const TextStyle(
                            fontFamily: 'Gabarito',
                            fontSize: 14,
                            color: AppColors.darker,
                          ),
                          children: [
                            TextSpan(
                              text: food.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: ' $expiryText'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        suggestion.cookingSuggestions.first,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Arrow
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetailBottomSheet(FoodItemModel food, FoodSuggestion suggestion) {
    final formattedDate = DateFormat('dd MMMM yyyy').format(food.expiryDate);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child:  Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors. grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Header with icon and title
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border. all(color: AppColors.normal. withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.light,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius. circular(8),
                              child: food.imageUrl != null && food.imageUrl!.isNotEmpty
                                  ? Image. network(
                                      food. imageUrl!,
                                      fit: BoxFit.cover,
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${food.name} akan kadaluarsa dalam ${food.daysUntilExpiry} hari! ',
                              style: const TextStyle(
                                fontFamily: 'Gabarito',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Tanggal Kadaluarsa
                    _buildDetailSection(
                      icon: Icons.calendar_today,
                      iconColor: Colors.orange,
                      title: 'Tanggal Kadaluarsa: ',
                      content: formattedDate,
                    ),

                    const SizedBox(height: 16),

                    // Saran Pengolahan
                    _buildDetailSection(
                      icon: Icons. restaurant,
                      iconColor: Colors.red,
                      title: 'Saran Pengolahan: ',
                      contentWidget: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: suggestion.cookingSuggestions.map((s) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('•  ', style: TextStyle(fontSize: 14)),
                                Expanded(
                                  child:  Text(
                                    s,
                                    style: TextStyle(
                                      fontSize:  14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tips Tambahan
                    _buildDetailSection(
                      icon: Icons. lightbulb_outline,
                      iconColor:  Colors.amber,
                      title: 'Tips Tambahan: ',
                      content: suggestion.storageTip,
                    ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              context.push('/foodDetail/${food.id}');
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.normal,
                              side: BorderSide(color: AppColors. normal),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Lihat Detail'),
                          ),
                        ),
                        const SizedBox(width:  12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              // Tandai sebagai sudah digunakan
                              _markAsUsed(food);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.normal,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Sudah Diolah',
                              style:  TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? content,
    Widget? contentWidget,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Gabarito',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              if (content != null)
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors. grey[700],
                  ),
                ),
              if (contentWidget != null) contentWidget,
            ],
          ),
        ),
      ],
    );
  }

  void _markAsUsed(FoodItemModel food) {
    _foodService.deleteFoodItem(food.id);
    ScaffoldMessenger. of(context).showSnackBar(
      SnackBar(
        content: Text('${food.name} telah ditandai sebagai sudah diolah'),
        backgroundColor: AppColors.normal,
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
      case 'roti':
        return Icons.bakery_dining;
      case 'frozen': 
        return Icons.ac_unit;
      default:
        return Icons.fastfood;
    }
  }
}