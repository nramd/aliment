import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:aliment/core/theme/app_colors.dart';
import 'package:aliment/features/models/shared_food_model.dart';
import 'package:aliment/features/services/share_service.dart';
import 'package:aliment/features/services/location_service.dart';
import 'package:aliment/features/services/auth_service.dart';

class SharedFoodDetailPage extends StatefulWidget {
  final String foodId;

  const SharedFoodDetailPage({
    super.key,
    required this.foodId,
  });

  @override
  State<SharedFoodDetailPage> createState() => _SharedFoodDetailPageState();
}

class _SharedFoodDetailPageState extends State<SharedFoodDetailPage> {
  final ShareService _shareService = ShareService();
  final LocationService _locationService = LocationService();
  final AuthService _authService = AuthService();

  bool _isRequesting = false;
  bool _hasRequested = false;
  String? _currentUserId;
  String _currentUserName = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = _authService.currentUser;
    if (user != null) {
      _currentUserId = user.uid;
      final userData = await _authService.getUserData(user.uid);
      if (userData != null && mounted) {
        setState(() {
          _currentUserName = userData.displayName;
        });
      } else if (user.displayName != null && mounted) {
        setState(() {
          _currentUserName = user.displayName!;
        });
      }
      // Check if already requested
      _checkIfAlreadyRequested();
    }
  }

  Future<void> _checkIfAlreadyRequested() async {
    if (_currentUserId != null) {
      final hasRequested = await _shareService.hasUserRequested(
        widget.foodId,
        _currentUserId!,
      );
      if (mounted) {
        setState(() {
          _hasRequested = hasRequested;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      body: StreamBuilder<SharedFoodModel?>(
        stream: _shareService.streamSharedFood(widget.foodId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final food = snapshot.data;

          if (food == null) {
            return _buildNotFound();
          }

          final isOwner = _currentUserId == food.ownerId;

          return CustomScrollView(
            slivers: [
              // App Bar with Image
              _buildSliverAppBar(food),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Category
                      _buildTitleSection(food),

                      const SizedBox(height: 16),

                      // Owner Info
                      _buildOwnerSection(food),

                      const SizedBox(height: 16),

                      // Details
                      _buildDetailsSection(food),

                      const SizedBox(height: 16),

                      // Description
                      if (food.description != null &&
                          food.description!.isNotEmpty)
                        _buildDescriptionSection(food),

                      const SizedBox(height: 16),

                      // Location
                      _buildLocationSection(food),

                      const SizedBox(height: 24),

                      // Request Info
                      _buildRequestInfoSection(food),

                      const SizedBox(height: 24),

                      // Action Button
                      if (!isOwner) _buildActionButton(food),

                      if (isOwner) _buildOwnerActions(food),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotFound() {
    return SafeArea(
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.darker),
              onPressed: () => context.pop(),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'Makanan tidak ditemukan',
                    style: TextStyle(
                      fontFamily: 'Gabarito',
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mungkin sudah tidak tersedia',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.normal,
                    ),
                    child: const Text('Kembali',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(SharedFoodModel food) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.light,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darker),
          onPressed: () => context.pop(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: food.imageUrl != null && food.imageUrl!.isNotEmpty
            ? Image.network(
                food.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _buildPlaceholderImage(food.category),
              )
            : _buildPlaceholderImage(food.category),
      ),
    );
  }

  Widget _buildPlaceholderImage(String category) {
    return Container(
      color: AppColors.light,
      child: Center(
        child: Icon(
          _getCategoryIcon(category),
          size: 80,
          color: AppColors.normal.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildTitleSection(SharedFoodModel food) {
    final Color statusColor = food.daysUntilExpiry < 0
        ? Colors.red
        : food.daysUntilExpiry <= 3
            ? Colors.orange
            : AppColors.normal;

    final String expiryText = food.daysUntilExpiry < 0
        ? 'Sudah Kadaluarsa'
        : food.daysUntilExpiry == 0
            ? 'Kadaluarsa Hari Ini'
            : '${food.daysUntilExpiry} hari lagi';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                food.name,
                style: const TextStyle(
                  fontFamily: 'Gabarito',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darker,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    food.daysUntilExpiry < 0
                        ? Icons.warning
                        : Icons.access_time,
                    size: 14,
                    color: statusColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    expiryText,
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.normal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            food.category,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.normal,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOwnerSection(SharedFoodModel food) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.normal,
            child: Text(
              food.ownerName.isNotEmpty ? food.ownerName[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.ownerName,
                  style: const TextStyle(
                    fontFamily: 'Gabarito',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Dibagikan ${_formatDate(food.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (_currentUserId == food.ownerId)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.normal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Milik Anda',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.normal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(SharedFoodModel food) {
    final formattedExpiry = DateFormat('dd MMMM yyyy').format(food.expiryDate);

    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          _buildDetailRow(
            icon: Icons.inventory_2_outlined,
            label: 'Jumlah',
            value: '${food.quantity} ${food.unit}',
          ),
          const Divider(height: 24),
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Tanggal Kadaluarsa',
            value: formattedExpiry,
          ),
          const Divider(height: 24),
          _buildDetailRow(
            icon: Icons.info_outline,
            label: 'Status',
            value: _getStatusText(food.status),
            valueColor: _getStatusColor(food.status),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.normal),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.darker,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(SharedFoodModel food) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes, size: 20, color: AppColors.normal),
              const SizedBox(width: 8),
              const Text(
                'Catatan',
                style: TextStyle(
                  fontFamily: 'Gabarito',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            food.description!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(SharedFoodModel food) {
    final hasLocation = food.location != null ||
        (food.address != null && food.address!.isNotEmpty);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, size: 20, color: AppColors.normal),
              const SizedBox(width: 8),
              const Text(
                'Lokasi Pengambilan',
                style: TextStyle(
                  fontFamily: 'Gabarito',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (food.address != null && food.address!.isNotEmpty)
            Text(
              food.address!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          if (food.location != null) ...[
            if (food.address != null && food.address!.isNotEmpty)
              const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _locationService.openInGoogleMaps(
                    food.location!.latitude,
                    food.location!.longitude,
                  );
                },
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text('Buka di Google Maps'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.normal,
                  side: BorderSide(color: AppColors.normal),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
          if (!hasLocation)
            Text(
              'Lokasi belum ditentukan',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRequestInfoSection(SharedFoodModel food) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.normal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.normal.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.people_outline, color: AppColors.normal, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.requestCount > 0
                      ? '${food.requestCount} orang sudah request'
                      : 'Belum ada yang request',
                  style: const TextStyle(
                    fontFamily: 'Gabarito',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  food.isAvailable
                      ? 'Makanan masih tersedia'
                      : food.isReserved
                          ? 'Sudah ada yang terpilih'
                          : 'Tidak tersedia',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(SharedFoodModel food) {
    // Jika sudah request
    if (_hasRequested) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty, color: Colors.orange, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Anda sudah mengajukan permintaan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      );
    }

    // Jika tidak available
    if (!food.isAvailable) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, color: Colors.grey, size: 20),
            const SizedBox(width: 8),
            Text(
              food.isReserved ? 'Sudah direservasi' : 'Tidak tersedia',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    // Tombol ajukan permintaan
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isRequesting ? null : () => _showRequestDialog(food),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.normal,
          disabledBackgroundColor: Colors.grey[300],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isRequesting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Ajukan Permintaan',
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

  Widget _buildOwnerActions(SharedFoodModel food) {
    return Column(
      children: [
        if (food.isAvailable && food.requestCount > 0)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/requestQueue/${food.id}'),
              icon: const Icon(Icons.list_alt, size: 18),
              label: Text('Lihat Antrian (${food.requestCount})'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.normal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        if (food.isReserved) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _confirmMarkAsCompleted(food),
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Tandai Sudah Diambil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        if (food.isAvailable)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _confirmCancelShare(food),
              icon: Icon(Icons.close, size: 18, color: Colors.red[400]),
              label: Text('Batalkan Berbagi',
                  style: TextStyle(color: Colors.red[400])),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showRequestDialog(SharedFoodModel food) {
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Ajukan Permintaan',
                style: TextStyle(
                  fontFamily: 'Gabarito',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Anda akan mengajukan permintaan untuk "${food.name}"',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                      'Tambahkan catatan (opsional)\nContoh: Bisa ambil sore ini jam 5',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                  filled: true,
                  fillColor: AppColors.light,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _submitRequest(food, noteController.text.trim());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.normal,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ajukan',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitRequest(SharedFoodModel food, String note) async {
    if (_currentUserId == null) return;

    setState(() {
      _isRequesting = true;
    });

    try {
      await _shareService.createRequest(
        sharedFood: food,
        requesterId: _currentUserId!,
        requesterName: _currentUserName,
        note: note.isNotEmpty ? note : null,
      );

      if (mounted) {
        setState(() {
          _isRequesting = false;
          _hasRequested = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permintaan berhasil diajukan! '),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRequesting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengajukan permintaan:  $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmMarkAsCompleted(SharedFoodModel food) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
            const Text('Konfirmasi', style: TextStyle(fontFamily: 'Gabarito')),
        content: Text('Tandai "${food.name}" sebagai sudah diambil?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (food.selectedRequestId != null) {
                await _shareService.markAsCompleted(
                  food.selectedRequestId!,
                  food.id,
                  food.foodId,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Berhasil ditandai selesai!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.pop();
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Ya, Selesai',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmCancelShare(SharedFoodModel food) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Batalkan Berbagi',
            style: TextStyle(fontFamily: 'Gabarito')),
        content: Text(
            'Batalkan membagikan "${food.name}"?\n\nSemua permintaan yang masuk akan otomatis ditolak.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tidak', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _shareService.cancelSharedFood(food.id, food.foodId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Berbagi dibatalkan'),
                    backgroundColor: Colors.orange,
                  ),
                );
                context.pop();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ya, Batalkan',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'available':
        return 'Tersedia';
      case 'reserved':
        return 'Direservasi';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'available':
        return Colors.green;
      case 'reserved':
        return Colors.blue;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.darker;
    }
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
      case 'dairy':
        return Icons.egg;
      default:
        return Icons.fastfood;
    }
  }
}
