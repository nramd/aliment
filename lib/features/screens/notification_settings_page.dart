import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aliment/core/theme/app_colors.dart';
import 'package:aliment/features/services/notification_service.dart';
import 'package:aliment/features/services/auth_service.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final NotificationService _notificationService = NotificationService();
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  bool _notificationEnabled = true;
  int _reminderDays = 3;
  int _reminderHour = 8;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await _notificationService.isNotificationEnabled();
    final days = await _notificationService.getReminderDays();
    final hour = await _notificationService. getReminderTimeHour();

    setState(() {
      _notificationEnabled = enabled;
      _reminderDays = days;
      _reminderHour = hour;
      _isLoading = false;
    });
  }

  Future<void> _toggleNotification(bool value) async {
    setState(() => _notificationEnabled = value);
    await _notificationService.setNotificationEnabled(value);

    if (value) {
      // Request permission dan schedule notifications
      final granted = await _notificationService.requestPermission();
      if (granted) {
        final user = _authService.currentUser;
        if (user != null) {
          await _notificationService.checkAndScheduleExpiryNotifications(user.uid);
        }
        _showSnackBar('Notifikasi diaktifkan');
      } else {
        setState(() => _notificationEnabled = false);
        await _notificationService.setNotificationEnabled(false);
        _showSnackBar('Izin notifikasi ditolak', isError: true);
      }
    } else {
      _showSnackBar('Notifikasi dinonaktifkan');
    }
  }

  Future<void> _updateReminderDays(int days) async {
    setState(() => _reminderDays = days);
    await _notificationService. setReminderDays(days);
    await _refreshNotifications();
  }

  Future<void> _updateReminderHour(int hour) async {
    setState(() => _reminderHour = hour);
    await _notificationService.setReminderTimeHour(hour);
    await _refreshNotifications();
  }

  Future<void> _refreshNotifications() async {
    if (! _notificationEnabled) return;
    
    final user = _authService.currentUser;
    if (user != null) {
      await _notificationService.checkAndScheduleExpiryNotifications(user.uid);
      _showSnackBar('Pengaturan notifikasi diperbarui');
    }
  }

  Future<void> _testNotification() async {
    await _notificationService.showNotification(
      id: 0,
      title: '🧪 Test Notifikasi',
      body: 'Ini adalah test notifikasi dari Aliment.  Notifikasi berfungsi dengan baik! ',
    );
    _showSnackBar('Test notifikasi dikirim');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ?  Colors.red : AppColors.normal,
      ),
    );
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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
                    'Pengaturan Notifikasi',
                    style: TextStyle(
                      fontFamily: 'Gabarito',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Atur reminder untuk makanan yang akan kadaluarsa',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Enable/Disable Notification
                    _buildSettingCard(
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Aktifkan Notifikasi',
                          style: TextStyle(
                            fontFamily: 'Gabarito',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Terima pengingat untuk makanan yang akan kadaluarsa',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors. grey[600],
                          ),
                        ),
                        value: _notificationEnabled,
                        onChanged: _toggleNotification,
                        activeColor: AppColors.normal,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Reminder Days
                    _buildSettingCard(
                      child: Column(
                        crossAxisAlignment:  CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today, 
                                  color: AppColors.normal, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Ingatkan Sebelum Kadaluarsa',
                                style: TextStyle(
                                  fontFamily: 'Gabarito',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: [1, 2, 3, 5, 7].map((days) {
                              final isSelected = _reminderDays == days;
                              return ChoiceChip(
                                label: Text('$days hari'),
                                selected: isSelected,
                                onSelected:  _notificationEnabled
                                    ? (selected) {
                                        if (selected) _updateReminderDays(days);
                                      }
                                    : null,
                                selectedColor: AppColors.normal,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.darker,
                                  fontFamily:  'Gabarito',
                                ),
                                backgroundColor:  Colors.grey[100],
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Anda akan diingatkan $_reminderDays hari sebelum makanan kadaluarsa',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height:  16),

                    // Reminder Time
                    _buildSettingCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.access_time, 
                                  color:  AppColors.normal, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Waktu Notifikasi',
                                style:  TextStyle(
                                  fontFamily: 'Gabarito',
                                  fontWeight:  FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [6, 7, 8, 9, 12, 18, 20].map((hour) {
                              final isSelected = _reminderHour == hour;
                              String label;
                              if (hour < 12) {
                                label = '$hour:00 AM';
                              } else if (hour == 12) {
                                label = '12:00 PM';
                              } else {
                                label = '${hour - 12}:00 PM';
                              }
                              return ChoiceChip(
                                label: Text(label),
                                selected: isSelected,
                                onSelected: _notificationEnabled
                                    ? (selected) {
                                        if (selected) _updateReminderHour(hour);
                                      }
                                    : null,
                                selectedColor: AppColors.normal,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors. white : AppColors.darker,
                                  fontFamily: 'Gabarito',
                                  fontSize: 12,
                                ),
                                backgroundColor: Colors.grey[100],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:  AppColors.normal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.normal),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:  CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tentang Notifikasi',
                                  style: TextStyle(
                                    fontFamily: 'Gabarito',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Notifikasi akan dikirim setiap hari pada waktu yang dipilih untuk makanan yang akan kadaluarsa.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:  Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Test Notification Button
                    SizedBox(
                      width:  double.infinity,
                      child: OutlinedButton. icon(
                        onPressed:  _notificationEnabled ? _testNotification :  null,
                        icon: const Icon(Icons.notifications_active),
                        label: const Text('Test Notifikasi'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.normal,
                          side: BorderSide(color: AppColors.normal),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius. circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}