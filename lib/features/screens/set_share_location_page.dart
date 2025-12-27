import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aliment/core/theme/app_colors.dart';
import 'package:aliment/features/models/food_item_model.dart';
import 'package:aliment/features/services/share_service.dart';
import 'package:aliment/features/services/location_service.dart';
import 'package:aliment/features/services/auth_service.dart';

class SetShareLocationPage extends StatefulWidget {
  final FoodItemModel food;

  const SetShareLocationPage({
    super.key,
    required this.food,
  });

  @override
  State<SetShareLocationPage> createState() => _SetShareLocationPageState();
}

class _SetShareLocationPageState extends State<SetShareLocationPage> {
  final ShareService _shareService = ShareService();
  final LocationService _locationService = LocationService();
  final AuthService _authService = AuthService();

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  GeoPoint? _selectedLocation;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      final userData = await _authService.getUserData(user.uid);
      if (userData != null && mounted) {
        setState(() {
          _userName = userData. displayName;
        });
      } else if (user.displayName != null && mounted) {
        setState(() {
          _userName = user.displayName!;
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final position = await _locationService.getCurrentLocation();

      if (position != null && mounted) {
        setState(() {
          _selectedLocation = _locationService.positionToGeoPoint(position);
          _isLoadingLocation = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lokasi berhasil didapatkan! '),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak dapat mengakses lokasi.  Periksa izin lokasi.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:  Text('Error: $e'),
            backgroundColor:  Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitShare() async {
    // Validasi
    if (_addressController.text.trim().isEmpty && _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan alamat atau gunakan lokasi GPS'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _shareService.shareFoodFromEtalase(
        food:  widget.food,
        ownerName: _userName,
        location:  _selectedLocation,
        address: _addressController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      if (mounted) {
        // Tampilkan dialog sukses
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger. of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membagikan:  $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors. green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
            ),
            const SizedBox(height:  24),
            const Text(
              'Berhasil Dibagikan! ',
              style: TextStyle(
                fontFamily: 'Gabarito',
                fontSize:  20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.food.name} sekarang dapat dilihat oleh orang lain di sekitar Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator. pop(context); // Close dialog
                  context.go('/home'); // Go to home
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.normal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:  const Text(
                  'Kembali ke Beranda',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                context. pop(); // Go back
                context.pop(); // Go back to share tab
              },
              child: Text(
                'Bagikan Lagi',
                style: TextStyle(color: AppColors.normal),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      appBar: AppBar(
        backgroundColor: AppColors.light,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons. arrow_back, color: AppColors.darker),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Atur Lokasi',
          style: TextStyle(
            fontFamily: 'Gabarito',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darker,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Preview Card
            _buildFoodPreview(),

            const SizedBox(height: 24),

            // Location Section
            const Text(
              'Lokasi Pengambilan',
              style: TextStyle(
                fontFamily: 'Gabarito',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darker,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tentukan lokasi agar penerima bisa mengambil makanan',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height:  16),

            // GPS Button
            _buildGPSButton(),

            const SizedBox(height: 16),

            // Divider with "atau"
            Row(
              children: [
                Expanded(child:  Divider(color: Colors.grey[300])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'atau',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                ),
                Expanded(child:  Divider(color: Colors.grey[300])),
              ],
            ),

            const SizedBox(height: 16),

            // Manual Address Input
            _buildAddressInput(),

            const SizedBox(height: 24),

            // Description (Optional)
            const Text(
              'Catatan (Opsional)',
              style:  TextStyle(
                fontFamily:  'Gabarito',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darker,
              ),
            ),
            const SizedBox(height:  8),
            _buildDescriptionInput(),

            const SizedBox(height: 32),

            // Submit Button
            _buildSubmitButton(),

            const SizedBox(height:  16),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow:  [
          BoxShadow(
            color: Colors.black. withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: widget.food.imageUrl != null && widget.food.imageUrl!. isNotEmpty
                ? Image. network(
                    widget.food.imageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                  )
                : _buildPlaceholderImage(),
          ),
          const SizedBox(width:  12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment. start,
              children: [
                Text(
                  widget. food.name,
                  style: const TextStyle(
                    fontFamily: 'Gabarito',
                    fontWeight:  FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding:  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.normal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.food.category,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.normal,
                          fontWeight: FontWeight. w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget. food.quantity} ${widget.food.unit}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${widget.food. daysUntilExpiry} hari',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 60,
      height: 60,
      color: AppColors.light,
      child: Icon(Icons.fastfood, color: AppColors.normal),
    );
  }

  Widget _buildGPSButton() {
    return InkWell(
      onTap: _isLoadingLocation ? null : _getCurrentLocation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _selectedLocation != null
              ? Colors.green.withOpacity(0.1)
              : Colors. white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedLocation != null
                ? Colors.green
                : AppColors.normal.withOpacity(0.3),
            width: _selectedLocation != null ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _selectedLocation != null
                    ?  Colors.green. withOpacity(0.2)
                    : AppColors.normal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: _isLoadingLocation
                  ? SizedBox(
                      width:  20,
                      height:  20,
                      child:  CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.normal,
                      ),
                    )
                  :  Icon(
                      _selectedLocation != null
                          ?  Icons.check_circle
                          : Icons. my_location,
                      color:  _selectedLocation != null
                          ?  Colors.green
                          : AppColors.normal,
                      size: 20,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedLocation != null
                        ? 'Lokasi GPS Didapatkan'
                        :  'Gunakan Lokasi Saat Ini',
                    style: TextStyle(
                      fontFamily: 'Gabarito',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: _selectedLocation != null
                          ? Colors.green
                          : AppColors.darker,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _selectedLocation != null
                        ? 'Lat: ${_selectedLocation!.latitude. toStringAsFixed(4)}, Lng: ${_selectedLocation!.longitude.toStringAsFixed(4)}'
                        : 'Klik untuk mendapatkan lokasi GPS',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors. grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (_selectedLocation != null)
              IconButton(
                icon: Icon(Icons.close, color: Colors.grey[400], size: 20),
                onPressed: () {
                  setState(() {
                    _selectedLocation = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressInput() {
    return TextField(
      controller: _addressController,
      maxLines: 2,
      decoration: InputDecoration(
        hintText: 'Masukkan alamat lengkap.. .',
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        prefixIcon:  Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Icon(Icons.location_on_outlined, color: AppColors.normal),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius:  BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:  BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey. withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.normal, width: 2),
        ),
      ),
    );
  }

  Widget _buildDescriptionInput() {
    return TextField(
      controller: _descriptionController,
      maxLines: 3,
      decoration:  InputDecoration(
        hintText: 'Contoh:  Bisa diambil setelah jam 5 sore, hubungi dulu sebelum datang...',
        hintStyle: TextStyle(color: Colors. grey[400], fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
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
    );
  }

  Widget _buildSubmitButton() {
    final bool canSubmit = ! _isSubmitting &&
        (_selectedLocation != null || _addressController. text.trim().isNotEmpty);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canSubmit ?  _submitShare : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.normal,
          disabledBackgroundColor: Colors.grey[300],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width:  20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Bagikan Sekarang',
                style: TextStyle(
                  fontFamily: 'Gabarito',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}