import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aliment/core/theme/app_colors.dart';
import 'package:aliment/features/services/auth_service.dart';
import 'package:aliment/features/models/food_item_model.dart';

class AddFoodPage extends StatefulWidget {
  const AddFoodPage({super.key});

  @override
  State<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _expiryDaysController = TextEditingController(text: '7');

  File? _selectedImage;
  String? _selectedImageName;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _expiryDaysController. dispose();
    super.dispose();
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

  void _navigateToPreview() {
    if (!_formKey.currentState!.validate()) return;

    final user = _authService.currentUser;
    if (user == null) return;

    final expiryDays = int.tryParse(_expiryDaysController.text) ?? 7;

    final previewFood = FoodItemModel(
      id: '',
      userId: user.uid,
      name: _nameController.text. trim(),
      category: 'Lainnya',
      expiryDate: DateTime. now().add(Duration(days: expiryDays)),
      addedDate: DateTime.now(),
      storageLocation: 'Kulkas',
      quantity: int.tryParse(_quantityController.text) ?? 1,
      unit: _unitController.text.trim().isEmpty ? 'pcs' : _unitController.text.trim(),
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
              padding:  const EdgeInsets.all(16.0),
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
                      fontWeight:  FontWeight.bold,
                      color: AppColors.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tambahkan bahan makanan baru ke etalase anda',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors. grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Custom Tab Bar - DIPERBAIKI
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
                  indicatorPadding: const EdgeInsets. all(4),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.normal,
                  labelStyle: const TextStyle(
                    fontFamily: 'Gabarito',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontFamily:  'Gabarito',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(text:  'Input Manual'),
                    Tab(text:  'Scan Barcode'),
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
                  _buildScanBarcodeTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                  border: Border.all(color: Colors.grey. withOpacity(0.3)),
                ),
                child: _selectedImage != null
                    ? Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image. file(
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
                              style: const TextStyle(
                                fontFamily: 'Gabarito',
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          IconButton(
                            icon:  const Icon(Icons.close, color: Colors.grey),
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
                          Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.grey[600],
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:  CrossAxisAlignment.start,
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
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
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

            // Berat/Jumlah
            _buildLabel('Berat/Jumlah'),
            TextFormField(
              controller: _quantityController,
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
              decoration: _inputDecoration('Contoh: Gram'),
            ),

            const SizedBox(height: 16),

            // Kadaluarsa Dalam (Hari)
            _buildLabel('Kadaluarsa Dalam (Hari)'),
            TextFormField(
              controller: _expiryDaysController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('7'),
            ),

            const SizedBox(height: 24),

            // Tombol Tambah
            SizedBox(
              width: double.infinity,
              height: 50,
              child:  ElevatedButton(
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

            const SizedBox(height:  24),

            // Tips Penggunaan
            const Text(
              'Tips Penggunaan',
              style: TextStyle(
                fontFamily: 'Gabarito',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height:  8),
            _buildTipItem('Pastikan nama makanan diisi dengan lengkap dan jelas'),
            _buildTipItem('Isi berat atau jumlah sesuai dengan kemasan asli'),
            _buildTipItem('Perkirakan hari kadaluarsa dari tanggal pembelian'),

            const SizedBox(height:  40),
          ],
        ),
      ),
    );
  }

  Widget _buildScanBarcodeTab() {
    return SingleChildScrollView(
      child:  Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child:  Icon(
                Icons.qr_code_scanner,
                size: 100,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton. icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur Scan Barcode Coming Soon'),
                  ),
                );
              },
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: const Text(
                'Buka Kamera',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.normal,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
            const SizedBox(height: 40),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tips Penggunaan',
                  style:  TextStyle(
                    fontFamily: 'Gabarito',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTipItem('Pastikan barcode terlihat jelas'),
                _buildTipItem('Arahkan kamera tepat ke barcode'),
                _buildTipItem('Pastikan pencahayaan cukup'),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
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
        borderRadius:  BorderRadius.circular(12),
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
              style:  TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}