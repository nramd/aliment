import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aliment/core/theme/app_colors.dart';
import 'package:aliment/features/services/auth_service.dart';
import 'package:aliment/features/models/food_item_model.dart';
import 'package:aliment/features/models/food_template_model.dart';

class AddFoodPage extends StatefulWidget {
  const AddFoodPage({super.key});

  @override
  State<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  // Controllers untuk Input Manual
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _expiryDaysController =
      TextEditingController(text: '7');
  String _selectedCategory = 'Lainnya';

  // Untuk Quick Add
  final TextEditingController _searchController = TextEditingController();
  String _selectedQuickCategory = 'Semua';
  List<FoodTemplate> _filteredTemplates = FoodTemplateData.templates;

  File? _selectedImage;
  String? _selectedImageName;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _expiryDaysController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterTemplates();
  }

  void _filterTemplates() {
    setState(() {
      List<FoodTemplate> results = FoodTemplateData.templates;

      // Filter by category
      if (_selectedQuickCategory != 'Semua') {
        results =
            results.where((t) => t.category == _selectedQuickCategory).toList();
      }

      // Filter by search query
      if (_searchController.text.isNotEmpty) {
        results = results
            .where((t) => t.name
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList();
      }

      _filteredTemplates = results;
    });
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/etalase');
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _selectedImageName = image.name;
      });
    }
  }

  void _selectTemplate(FoodTemplate template) {
    // Pindah ke tab Input Manual dan isi form dengan data template
    _tabController.animateTo(0);

    setState(() {
      _nameController.text = template.name;
      _quantityController.text = template.defaultQuantity.toString();
      _unitController.text = template.defaultUnit;
      _expiryDaysController.text = template.defaultExpiryDays.toString();
      _selectedCategory = template.category;
    });

    // Tampilkan snackbar konfirmasi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('${template.name} dipilih!  Silakan sesuaikan jika perlu.'),
        backgroundColor: AppColors.normal,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToPreview() {
    if (!_formKey.currentState!.validate()) return;

    final user = _authService.currentUser;
    if (user == null) return;

    final expiryDays = int.tryParse(_expiryDaysController.text) ?? 7;

    final previewFood = FoodItemModel(
      id: '',
      userId: user.uid,
      name: _nameController.text.trim(),
      category: _selectedCategory,
      expiryDate: DateTime.now().add(Duration(days: expiryDays)),
      addedDate: DateTime.now(),
      storageLocation: 'Kulkas',
      quantity: int.tryParse(_quantityController.text) ?? 1,
      unit: _unitController.text.trim().isEmpty
          ? 'pcs'
          : _unitController.text.trim(),
      status: 'available',
    );

    context.push('/previewFood', extra: {
      'food': previewFood,
      'imageFile': _selectedImage,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
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
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tambah Bahan Makanan',
                    style: TextStyle(
                      fontFamily: 'Gabarito',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tambahkan bahan makanan baru ke etalase anda',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tab Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: AppColors.normal, width: 1.5),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: AppColors.normal,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  indicatorPadding: const EdgeInsets.all(4),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.normal,
                  labelStyle: const TextStyle(
                    fontFamily: 'Gabarito',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: 'Gabarito',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(text: 'Input Manual'),
                    Tab(text: 'Quick Add'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildManualInputTab(),
                  _buildQuickAddTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // INPUT MANUAL
  Widget _buildManualInputTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload Gambar
            InkWell(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: _selectedImage != null
                    ? Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _selectedImage!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedImageName ?? 'Image',
                              style: const TextStyle(fontFamily: 'Gabarito'),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _selectedImage = null;
                                _selectedImageName = null;
                              });
                            },
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Icon(Icons.camera_alt_outlined,
                              color: Colors.grey[600], size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Upload Gambar',
                                  style: TextStyle(
                                    fontFamily: 'Gabarito',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Ambil/Upload Gambar Makanan',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600]),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // Nama Makanan
            _buildLabel('Nama Makanan'),
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration('Masukkan nama makanan'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama makanan harus diisi';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Kategori (Dropdown)
            _buildLabel('Kategori'),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: _inputDecoration('Pilih kategori'),
              items: [
                'Lainnya',
                'Protein',
                'Sayuran',
                'Buah',
                'Dairy',
                'Makanan Kaleng',
                'Minuman',
                'Bumbu',
                'Roti',
                'Frozen',
              ].map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value!);
              },
            ),

            const SizedBox(height: 16),

            // Berat/Jumlah dan Satuan dalam satu Row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Berat/Jumlah'),
                      TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('0'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Wajib diisi';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Satuan'),
                      TextFormField(
                        controller: _unitController,
                        decoration: _inputDecoration('gram'),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Kadaluarsa Dalam (Hari)
            _buildLabel('Kadaluarsa Dalam (Hari)'),
            TextFormField(
              controller: _expiryDaysController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('7'),
            ),

            // Info Smart Default
            if (_nameController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.normal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_outline,
                          color: AppColors.normal, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tip: Gunakan tab "Quick Add" untuk mengisi otomatis berdasarkan jenis makanan! ',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.darker,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Tombol Tambah
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _navigateToPreview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.normal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Tambah Makanan',
                  style: TextStyle(
                    fontFamily: 'Gabarito',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tips Penggunaan
            const Text(
              'Tips Penggunaan',
              style: TextStyle(
                fontFamily: 'Gabarito',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            _buildTipItem(
                'Pastikan nama makanan diisi dengan lengkap dan jelas'),
            _buildTipItem('Isi berat atau jumlah sesuai dengan kemasan asli'),
            _buildTipItem('Perkirakan hari kadaluarsa dari tanggal pembelian'),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // QUICK ADD
  Widget _buildQuickAddTab() {
    final categories = ['Semua', ...FoodTemplateData.categories];

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari makanan...',
              prefixIcon: Icon(Icons.search, color: AppColors.normal),
              filled: true,
              fillColor: Colors.white,
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

        const SizedBox(height: 12),

        // Category Filter Chips
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = _selectedQuickCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedQuickCategory = category;
                      _filterTemplates();
                    });
                  },
                  backgroundColor: Colors.white,
                  selectedColor: AppColors.normal,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.darker,
                    fontFamily: 'Gabarito',
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.normal
                          : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Info Banner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.normal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.normal, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Add dengan Smart Defaults',
                        style: TextStyle(
                          fontFamily: 'Gabarito',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Pilih makanan untuk auto-fill estimasi kadaluarsa',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Template Grid
        Expanded(
          child: _filteredTemplates.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text(
                        'Tidak ada makanan ditemukan',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _filteredTemplates.length,
                  itemBuilder: (context, index) {
                    final template = _filteredTemplates[index];
                    return _buildTemplateCard(template);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTemplateCard(FoodTemplate template) {
    return InkWell(
      onTap: () => _selectTemplate(template),
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.normal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                template.icon,
                color: AppColors.normal,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            // Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                template.name,
                style: const TextStyle(
                  fontFamily: 'Gabarito',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            // Expiry days badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getExpiryColor(template.defaultExpiryDays)
                    .withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${template.defaultExpiryDays}d',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _getExpiryColor(template.defaultExpiryDays),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getExpiryColor(int days) {
    if (days <= 3) return Colors.red;
    if (days <= 7) return Colors.orange;
    if (days <= 30) return AppColors.normal;
    return Colors.blue;
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Gabarito',
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: AppColors.darker,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.normal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
