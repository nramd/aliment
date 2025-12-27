import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aliment/core/theme/app_colors.dart';
import 'package:aliment/features/services/share_service.dart';
import 'package:aliment/features/models/shared_food_model.dart';

class ShareExploreTab extends StatefulWidget {
  final String userId;

  const ShareExploreTab({
    super.key,
    required this.userId,
  });

  @override
  State<ShareExploreTab> createState() => _ShareExploreTabState();
}

class _ShareExploreTabState extends State<ShareExploreTab> {
  final ShareService _shareService = ShareService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedFilter = 'Semua';

  final List<String> _filters = [
    'Semua',
    'Terdekat',
    'Terbaru',
    'Segera Expired'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),

        // Search Bar
        _buildSearchBar(),

        const SizedBox(height: 12),

        // Filter Chips
        _buildFilterChips(),

        const SizedBox(height: 12),

        // Food List
        Expanded(
          child: StreamBuilder<List<SharedFoodModel>>(
            stream: _shareService.getAvailableSharedFoods(
                excludeUserId: widget.userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 60, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('Error: ${snapshot.error}'),
                    ],
                  ),
                );
              }

              final allFoods = snapshot.data ?? [];
              final filteredFoods = _filterFoods(allFoods);

              if (filteredFoods.isEmpty) {
                return _buildEmptyState(allFoods.isEmpty);
              }

              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredFoods.length,
                  itemBuilder: (context, index) {
                    return _buildFoodCard(filteredFoods[index]);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<SharedFoodModel> _filterFoods(List<SharedFoodModel> foods) {
    var result = List<SharedFoodModel>.from(foods);

    // Search filter
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((food) =>
              food.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              food.category.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Category filter
    switch (_selectedFilter) {
      case 'Terbaru':
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Segera Expired':
        result.sort((a, b) => a.daysUntilExpiry.compareTo(b.daysUntilExpiry));
        break;
      case 'Terdekat':
        // TODO: Implement distance sorting when location is available
        break;
    }

    return result;
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Cari makanan...',
          prefixIcon: Icon(Icons.search, color: AppColors.normal),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.normal, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = selected ? filter : 'Semua';
                });
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.normal,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.darker,
                fontFamily: 'Gabarito',
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.normal
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isNoData) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isNoData ? Icons.volunteer_activism_outlined : Icons.search_off,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            isNoData ? 'Belum ada makanan yang dibagikan' : 'Tidak ada hasil',
            style: const TextStyle(
              fontFamily: 'Gabarito',
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isNoData
                ? 'Jadilah yang pertama membagikan makanan!'
                : 'Coba ubah kata kunci pencarian',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard(SharedFoodModel food) {
    final Color statusColor = food.daysUntilExpiry < 0
        ? Colors.red
        : food.daysUntilExpiry <= 3
            ? Colors.orange
            : AppColors.normal;

    final String expiryText = food.daysUntilExpiry < 0
        ? 'Kadaluarsa'
        : food.daysUntilExpiry == 0
            ? 'Hari Ini'
            : '${food.daysUntilExpiry} hari lagi';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        onTap: () => context.push('/sharedFood/${food.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: food.imageUrl != null && food.imageUrl!.isNotEmpty
                    ? Image.network(
                        food.imageUrl!,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 90,
                            height: 90,
                            color: AppColors.light,
                            child: Icon(
                              _getCategoryIcon(food.category),
                              color: AppColors.normal,
                              size: 40,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 90,
                        height: 90,
                        color: AppColors.light,
                        child: Icon(
                          _getCategoryIcon(food.category),
                          color: AppColors.normal,
                          size: 40,
                        ),
                      ),
              ),
              const SizedBox(width: 12),

              // Food Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name & Category
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            food.name,
                            style: const TextStyle(
                              fontFamily: 'Gabarito',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
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
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Owner
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: AppColors.normal.withOpacity(0.2),
                          child: Text(
                            food.ownerName.isNotEmpty
                                ? food.ownerName[0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.normal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          food.ownerName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (food.address != null &&
                            food.address!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.location_on,
                              size: 12, color: Colors.grey[500]),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              food.address!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Quantity & Expiry
                    Row(
                      children: [
                        Text(
                          '${food.quantity} ${food.unit}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          food.daysUntilExpiry < 0
                              ? Icons.warning_amber_rounded
                              : Icons.access_time,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
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
                    const SizedBox(height: 8),

                    // Request count
                    Row(
                      children: [
                        Icon(Icons.people_outline,
                            size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          food.requestCount > 0
                              ? '${food.requestCount} orang request'
                              : 'Belum ada request',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.chevron_right,
                            size: 20, color: Colors.grey[400]),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
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
