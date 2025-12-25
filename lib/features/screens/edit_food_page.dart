import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:aliment/core/theme/app_colors.dart';
import 'package:aliment/features/services/food_service.dart';
import 'package:aliment/features/services/storage_service.dart';
import 'package:aliment/features/services/auth_service.dart';
import 'package:aliment/features/models/food_item_model.dart';

class EditFoodPage extends StatefulWidget {
  final String foodId;

  const EditFoodPage({
    super.key,
    required this.foodId,
  });

  @override
  State<EditFoodPage> createState() => _EditFoodPageState();
}

class _EditFoodPageState extends State<EditFoodPage> {
  final _formKey = GlobalKey<FormState>();
  final FoodService _foodService = FoodService();
  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();

  FoodItemModel? _originalFood;
  File? _newImage;
  String?  _currentImageUrl;
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 7));
  String _selectedCategory = 'Lainnya';

  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _categories = [
    'Lainnya',
    'Daging',
    'Protein',
    'Sayuran',
    'Buah',
    'Minuman',
    'Makanan Kaleng',
    'Dairy',
    'Bumbu',
  ];

  @override
  void initState() {
    super.initState();
    _loadFoodData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _loadFoodData() async {
    try {
      final food = await _foodService.getFoodByIdOnce(widget.foodId);
      if (food != null && mounted) {
        setState(() {
          _originalFood = food;
          _nameController.text = food.name;
          _quantityController.text = food.quantity. toString();
          _unitController. text = food.unit;
          _expiryDate = food.expiryDate;
          _selectedCategory = food.category;
          _currentImageUrl = food.imageUrl;
          _isLoading = false;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Makanan tidak ditemukan'),
              backgroundColor: Colors.red,
            ),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error:  $e'),
            backgroundColor: Colors. red,
          ),
        );
        context.pop();
      }
    }
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
        _newImage = File(image.path);
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime. now(),
      lastDate: DateTime. now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data:  Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.normal,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface:  AppColors.darker,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!. validate()) return;
    if (_originalFood == null) return;

    setState(() => _isSaving = true);

    try {
      String?  imageUrl = _currentImageUrl;

      // Upload gambar baru jika ada
      if (_newImage != null) {
        final user = _authService.currentUser;
        if (user != null) {
          imageUrl = await _storageService. uploadFoodImage(
            imageFile: _newImage!,
            userId: user.uid,
          );
        }
      }

      // Update food item
      final updatedFood = _originalFood! .copyWith(
        name: _nameController.text. trim(),
        quantity: int. tryParse(_quantityController.text) ?? 1,
        unit: _unitController.text.trim().isEmpty ? 'pcs' : _unitController.text.trim(),
        category: _selectedCategory,
        expiryDate: _expiryDate,
        imageUrl: imageUrl,
      );

      await _foodService.updateFoodItem(widget.foodId, updatedFood);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perubahan berhasil disimpan! '),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan:  $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.light,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
                    onTap: _isSaving ? null : _handleBack,
                    child: Row(
                      children: [
                        Icon(
                          Icons.chevron_left,
                          color: _isSaving ? Colors.grey : AppColors.darker,
                        ),
                        Text(
                          'Kembali',
                          style: TextStyle(
                            fontFamily: 'Gabarito',
                            color: _isSaving ? Colors.grey :  AppColors.darker,
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
                    'Edit Bahan Makanan',
                    style: TextStyle(
                      fontFamily: 'Gabarito',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Perbarui informasi bahan makanan',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gambar
                      InkWell(
                        onTap: _isSaving ? null : _pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.withOpacity(0.3)),
                          ),
                          child: _buildImagePreview(),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Nama Makanan
                      _buildLabel('Nama Makanan'),
                      TextFormField(
                        controller:  _nameController,
                        decoration: _inputDecoration('Masukkan nama makanan'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama makanan harus diisi';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height:  16),

                      // Berat/Jumlah
                      _buildLabel('Berat/Jumlah'),
                      TextFormField(
                        controller:  _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('0'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Jumlah harus diisi';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Satuan
                      _buildLabel('Satuan'),
                      TextFormField(
                        controller: _unitController,
                        decoration: _inputDecoration('Contoh: gram'),
                      ),

                      const SizedBox(height: 16),

                      // Kategori
                      _buildLabel('Kategori'),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: _inputDecoration('Pilih Kategori'),
                        items:  _categories.map((category) {
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

                      // Tanggal Kadaluarsa
                      _buildLabel('Tanggal Kadaluarsa'),
                      InkWell(
                        onTap: _isSaving ? null : _selectDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.withOpacity(0.3)),
                          ),
                          child:  Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('dd MMMM yyyy').format(_expiryDate),
                                style: const TextStyle(fontSize: 16),
                              ),
                              Icon(Icons.calendar_today, color: AppColors.normal),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Tombol Simpan
                      SizedBox(
                        width:  double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveChanges,
                          style: ElevatedButton. styleFrom(
                            backgroundColor:  AppColors.normal,
                            disabledBackgroundColor: AppColors.normal.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width:  24,
                                  height: 24,
                                  child:  CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Simpan Perubahan',
                                  style: TextStyle(
                                    fontFamily: 'Gabarito',
                                    fontSize: 16,
                                    fontWeight:  FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 40),
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

  Widget _buildImagePreview() {
    if (_newImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(_newImage!, fit: BoxFit.cover),
            Positioned(
              top: 8,
              right: 8,
              child: InkWell(
                onTap: () => setState(() => _newImage = null),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color:  Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              _currentImageUrl!,
              fit: BoxFit. cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder();
              },
            ),
            Positioned(
              bottom: 8,
              right:  8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.normal,
                  borderRadius: BorderRadius.circular(20),
                ),
                child:  const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Ganti',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.camera_alt_outlined, color: Colors.grey[400], size: 40),
        const SizedBox(height: 8),
        Text(
          'Tap untuk upload gambar',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ],
    );
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
      fillColor:  Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
      enabledBorder:  OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:  BorderSide(color: Colors. grey.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:  BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.normal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors. red),
      ),
    );
  }
}