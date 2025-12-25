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
  final TextEditingController _searchController = TextEditingController();

  // Filter States
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  String _selectedExpiryFilter = 'Semua';
  String _selectedSort = 'Kadaluarsa Terdekat';

  // Show/Hide Filter Panel
  bool _showFilters = false;

  final List<String> _categories = [
    'Semua',
    'Protein',
    'Sayuran',
    'Buah',
    'Dairy',
    'Makanan Kaleng',
    'Minuman',
    'Bumbu',
    'Roti',
    'Frozen',
    'Lainnya',
  ];

  final List<String> _expiryFilters = [
    'Semua',
    'Aman',
    'Segera Olah',
    'Kadaluarsa',
  ];

  final List<String> _sortOptions = [
    'Kadaluarsa Terdekat',
    'Kadaluarsa Terjauh',
    'Nama A-Z',
    'Nama Z-A',
    'Terbaru Ditambahkan',
    'Terlama Ditambahkan',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategory = 'Semua';
      _selectedExpiryFilter = 'Semua';
      _selectedSort = 'Kadaluarsa Terdekat';
    });
  }

  // Filter dan Sort Logic
  List<FoodItemModel> _filterAndSortFoods(List<FoodItemModel> foods) {
    List<FoodItemModel> result = List.from(foods);

    // 1. Filter by Search Query
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((food) =>
              food.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // 2. Filter by Category
    if (_selectedCategory != 'Semua') {
      result =
          result.where((food) => food.category == _selectedCategory).toList();
    }

    // 3. Filter by Expiry Status
    if (_selectedExpiryFilter != 'Semua') {
      result = result.where((food) {
        switch (_selectedExpiryFilter) {
          case 'Aman':
            return food.daysUntilExpiry > 3;
          case 'Segera Olah':
            return food.daysUntilExpiry >= 0 && food.daysUntilExpiry <= 3;
          case 'Kadaluarsa':
            return food.daysUntilExpiry < 0;
          default:
            return true;
        }
      }).toList();
    }

    // 4. Sorting
    switch (_selectedSort) {
      case 'Kadaluarsa Terdekat':
        result.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
        break;
      case 'Kadaluarsa Terjauh':
        result.sort((a, b) => b.expiryDate.compareTo(a.expiryDate));
        break;
      case 'Nama A-Z':
        result.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case 'Nama Z-A':
        result.sort(
            (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case 'Terbaru Ditambahkan':
        result.sort((a, b) => b.addedDate.compareTo(a.addedDate));
        break;
      case 'Terlama Ditambahkan':
        result.sort((a, b) => a.addedDate.compareTo(b.addedDate));
        break;
    }

    return result;
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_selectedCategory != 'Semua') count++;
    if (_selectedExpiryFilter != 'Semua') count++;
    if (_selectedSort != 'Kadaluarsa Terdekat') count++;
    return count;
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
            // Header
            _buildHeader(),

            // Title Section
            _buildTitleSection(),

            const SizedBox(height: 12),

            // Search Bar
            _buildSearchBar(),

            const SizedBox(height: 12),

            // Quick Filter Chips (Expiry Status)
            _buildQuickFilterChips(),

            // Expanded Filter Panel
            if (_showFilters) _buildExpandedFilterPanel(),

            const SizedBox(height: 8),

            // Food List
            Expanded(
              child: StreamBuilder<List<FoodItemModel>>(
                stream: _foodService.getFoodItems(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(color: AppColors.normal),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  final allFoods = snapshot.data ?? [];
                  final filteredFoods = _filterAndSortFoods(allFoods);

                  // Stats untuk header
                  final stats = _calculateStats(allFoods);

                  return Column(
                    children: [
                      // Stats Bar
                      _buildStatsBar(
                          stats, allFoods.length, filteredFoods.length),

                      // List
                      Expanded(
                        child: filteredFoods.isEmpty
                            ? _buildEmptyState(allFoods.isEmpty)
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: filteredFoods.length,
                                itemBuilder: (context, index) {
                                  final food = filteredFoods[index];
                                  return _buildFoodCard(food);
                                },
                              ),
                      ),
                    ],
                  );
                },
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: _handleBack,
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
    );
  }

  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }

  Widget _buildSearchBar() {
    final activeFilters = _getActiveFilterCount();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Search Field
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari makanan...',
                prefixIcon: Icon(Icons.search, color: AppColors.normal),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
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
          ),

          const SizedBox(width: 8),

          // Filter Button
          InkWell(
            onTap: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _showFilters ? AppColors.normal : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _showFilters
                      ? AppColors.normal
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
              child: Stack(
                children: [
                  Icon(
                    Icons.tune,
                    color: _showFilters ? Colors.white : AppColors.darker,
                  ),
                  if (activeFilters > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$activeFilters',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _expiryFilters.length,
        itemBuilder: (context, index) {
          final filter = _expiryFilters[index];
          final isSelected = _selectedExpiryFilter == filter;

          Color chipColor;
          switch (filter) {
            case 'Aman':
              chipColor = Colors.green;
              break;
            case 'Segera Olah':
              chipColor = Colors.orange;
              break;
            case 'Kadaluarsa':
              chipColor = Colors.red;
              break;
            default:
              chipColor = AppColors.normal;
          }

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedExpiryFilter = selected ? filter : 'Semua';
                });
              },
              backgroundColor: Colors.white,
              selectedColor: chipColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.darker,
                fontFamily: 'Gabarito',
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? chipColor : Colors.grey.withOpacity(0.3),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpandedFilterPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter & Urutkan',
                style: TextStyle(
                  fontFamily: 'Gabarito',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              TextButton(
                onPressed: _resetFilters,
                child: Text(
                  'Reset',
                  style: TextStyle(
                    color: AppColors.normal,
                    fontFamily: 'Gabarito',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Kategori
          const Text(
            'Kategori',
            style: TextStyle(
              fontFamily: 'Gabarito',
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((category) {
              final isSelected = _selectedCategory == category;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.normal : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.normal
                          : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.darker,
                      fontSize: 12,
                      fontFamily: 'Gabarito',
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Urutkan
          const Text(
            'Urutkan',
            style: TextStyle(
              fontFamily: 'Gabarito',
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSort,
                isExpanded: true,
                items: _sortOptions.map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(
                      option,
                      style: const TextStyle(
                        fontFamily: 'Gabarito',
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSort = value!;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(Map<String, int> stats, int total, int filtered) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Result Count
          Text(
            filtered == total ? '$total item' : '$filtered dari $total item',
            style: TextStyle(
              fontFamily: 'Gabarito',
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
          // Status indicators
          Row(
            children: [
              _buildStatusIndicator(
                  '${stats['expired']}', Colors.red, 'Kadaluarsa'),
              const SizedBox(width: 12),
              _buildStatusIndicator(
                  '${stats['warning']}', Colors.orange, 'Segera Olah'),
              const SizedBox(width: 12),
              _buildStatusIndicator('${stats['safe']}', Colors.green, 'Aman'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String count, Color color, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            count,
            style: TextStyle(
              fontFamily: 'Gabarito',
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _calculateStats(List<FoodItemModel> foods) {
    int expired = 0;
    int warning = 0;
    int safe = 0;

    for (var food in foods) {
      if (food.daysUntilExpiry < 0) {
        expired++;
      } else if (food.daysUntilExpiry <= 3) {
        warning++;
      } else {
        safe++;
      }
    }

    return {
      'expired': expired,
      'warning': warning,
      'safe': safe,
    };
  }

  Widget _buildEmptyState(bool isNoData) {
    if (isNoData) {
      // Tidak ada data sama sekali
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.kitchen_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'Belum ada makanan tersimpan',
              style: TextStyle(
                fontFamily: 'Gabarito',
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan makanan pertamamu! ',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/addFood'),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Tambah Makanan',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.normal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    } else {
      // Ada data tapi filter tidak mengembalikan hasil
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada hasil',
              style: TextStyle(
                fontFamily: 'Gabarito',
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coba ubah kata kunci atau filter',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _resetFilters,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Filter'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.normal,
                side: BorderSide(color: AppColors.normal),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildFoodCard(FoodItemModel food) {
    final Color statusColor = food.daysUntilExpiry < 0
        ? Colors.red
        : food.daysUntilExpiry <= 3
            ? Colors.orange
            : AppColors.normal;

    final String expiryText = food.daysUntilExpiry < 0
        ? 'Kadaluarsa ${-food.daysUntilExpiry} hari lalu'
        : food.daysUntilExpiry == 0
            ? 'Kadaluarsa Hari Ini'
            : '${food.daysUntilExpiry} Hari lagi';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: food.daysUntilExpiry <= 3
            ? Border.all(color: statusColor.withOpacity(0.5), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.push('/foodDetail/${food.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food Image/Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.light,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: food.imageUrl != null && food.imageUrl!.isNotEmpty
                      ? Image.network(
                          food.imageUrl!,
                          fit: BoxFit.cover,
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
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              _getCategoryIcon(food.category),
                              color: AppColors.normal,
                              size: 30,
                            );
                          },
                        )
                      : Icon(
                          _getCategoryIcon(food.category),
                          color: AppColors.normal,
                          size: 30,
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Food Info - Expanded untuk mengisi ruang tersedia
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama makanan
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

                    // Quantity & Category dalam satu Row
                    Row(
                      children: [
                        Text(
                          '${food.quantity}${food.unit}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Category Badge - dipindah ke sini
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
                              fontSize: 11,
                              color: AppColors.normal,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Expiry Info
                    Row(
                      children: [
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
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Action Buttons - Fixed width column
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit Button
                  InkWell(
                    onTap: () => context.push('/editFood/${food.id}'),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.normal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.edit_outlined,
                        color: AppColors.normal,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Delete Button
                  InkWell(
                    onTap: () => _showDeleteDialog(food),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(FoodItemModel food) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Makanan',
          style: TextStyle(fontFamily: 'Gabarito'),
        ),
        content: Text('Apakah Anda yakin ingin menghapus "${food.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.white),
            ),
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
      case 'roti':
        return Icons.bakery_dining;
      case 'frozen':
        return Icons.ac_unit;
      default:
        return Icons.fastfood;
    }
  }
}
