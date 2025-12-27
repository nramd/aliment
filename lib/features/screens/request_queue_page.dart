import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:aliment/core/theme/app_colors.dart';
import 'package:aliment/features/services/share_service.dart';
import 'package:aliment/features/models/shared_food_model.dart';
import 'package:aliment/features/models/food_request_model.dart';

class RequestQueuePage extends StatefulWidget {
  final String sharedFoodId;

  const RequestQueuePage({
    super.key,
    required this.sharedFoodId,
  });

  @override
  State<RequestQueuePage> createState() => _RequestQueuePageState();
}

class _RequestQueuePageState extends State<RequestQueuePage> {
  final ShareService _shareService = ShareService();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      appBar: AppBar(
        backgroundColor: AppColors.light,
        elevation: 0,
        leading:  IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darker),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Antrian Permintaan',
          style: TextStyle(
            fontFamily: 'Gabarito',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darker,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<SharedFoodModel?>(
        stream: _shareService.streamSharedFood(widget.sharedFoodId),
        builder: (context, foodSnapshot) {
          if (foodSnapshot.connectionState == ConnectionState. waiting && !foodSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final food = foodSnapshot.data;

          if (food == null) {
            return _buildNotFound();
          }

          return Column(
            children: [
              // Food Info Card
              _buildFoodInfoCard(food),

              // Info Banner
              _buildInfoBanner(),

              // Queue List
              Expanded(
                child: StreamBuilder<List<FoodRequestModel>>(
                  stream: _shareService.getRequestsForFood(widget.sharedFoodId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    final requests = snapshot. data ?? [];

                    if (requests.isEmpty) {
                      return _buildEmptyQueue();
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        return _buildRequestCard(requests[index], food);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('Makanan tidak ditemukan'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.normal),
            child: const Text('Kembali', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodInfoCard(SharedFoodModel food) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:  Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: food.imageUrl != null && food.imageUrl! .isNotEmpty
                ? Image.network(
                    food. imageUrl!,
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
                  food. name,
                  style: const TextStyle(
                    fontFamily: 'Gabarito',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${food.quantity} ${food.unit} • Exp: ${food. daysUntilExpiry} hari',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors. grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.normal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${food.requestCount} antrian',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.normal,
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
      color: AppColors. light,
      child: Icon(Icons.fastfood, color: AppColors.normal),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange. withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons. info_outline, color: Colors.orange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Pilih satu penerima.  Yang lain akan otomatis ditolak.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyQueue() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Belum ada permintaan',
            style: TextStyle(
              fontFamily: 'Gabarito',
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tunggu sampai ada yang mengajukan permintaan',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(FoodRequestModel request, SharedFoodModel food) {
    final requestTime = _formatRequestTime(request.createdAt);

    return Container(
      margin:  const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.normal.withOpacity(0.2)),
        boxShadow:  [
          BoxShadow(
            color: Colors.black. withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - Queue Number & Time
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.normal,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#${request.queuePosition}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  requestTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Requester Info
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors. normal.withOpacity(0.2),
                child: Text(
                  request.requesterName.isNotEmpty
                      ? request.requesterName[0].toUpperCase()
                      : 'U',
                  style:  TextStyle(
                    color: AppColors.normal,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.requesterName,
                      style:  const TextStyle(
                        fontFamily: 'Gabarito',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    if (request.note != null && request.note!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors. light,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.format_quote, size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                request.note!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isProcessing ? null : () => _confirmReject(request),
                  icon: Icon(Icons.close, size: 18, color: Colors.red[400]),
                  label: Text('Tolak', style: TextStyle(color: Colors.red[400])),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red. withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width:  12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null :  () => _confirmAccept(request, food),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Terima'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.normal,
                    foregroundColor: Colors. white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape:  RoundedRectangleBorder(
                      borderRadius:  BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmAccept(FoodRequestModel request, SharedFoodModel food) {
    final otherRequestsCount = food.requestCount - 1;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Terima Permintaan', style: TextStyle(fontFamily: 'Gabarito')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Terima permintaan dari ${request.requesterName}? '),
            if (otherRequestsCount > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:  Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$otherRequestsCount permintaan lainnya akan otomatis ditolak',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _acceptRequest(request);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.normal),
            child: const Text('Ya, Terima', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmReject(FoodRequestModel request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tolak Permintaan', style: TextStyle(fontFamily: 'Gabarito')),
        content: Text('Tolak permintaan dari ${request. requesterName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Colors. grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectRequest(request);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ya, Tolak', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptRequest(FoodRequestModel request) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      await _shareService.acceptRequest(request.id, widget.sharedFoodId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Permintaan ${request.requesterName} diterima! '),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(); // Kembali ke halaman sebelumnya
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menerima permintaan:  $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectRequest(FoodRequestModel request) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      await _shareService.rejectRequest(request.id);

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Permintaan ${request.requesterName} ditolak'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menolak permintaan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatRequestTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Baru saja';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    } else {
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    }
  }
}