import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_item_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Notification Channel
  static const String _channelId = 'aliment_expiry_channel';
  static const String _channelName = 'Expiry Reminders';
  static const String _channelDesc = 'Notifikasi untuk makanan yang akan kadaluarsa';

  // SharedPreferences Keys
  static const String _keyNotificationEnabled = 'notification_enabled';
  static const String _keyReminderDays = 'reminder_days';
  static const String _keyReminderTime = 'reminder_time_hour';

  // Initialize Notification Service
  Future<void> initialize() async {
    // Initialize timezone
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz. getLocation('Asia/Jakarta'));

    // Android Settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission:  true,
    );

    // Initialize
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    await _createNotificationChannel();
  }

  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description:  _channelDesc,
      importance: Importance.high,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - bisa navigate ke halaman tertentu
    debugPrint('Notification tapped:  ${response.payload}');
  }

  // Request Permission
  Future<bool> requestPermission() async {
    // iOS
    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ??  false;
    }

    // Android 13+
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    return true;
  }

  // SETTINGS 

  Future<bool> isNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotificationEnabled) ?? true;
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationEnabled, enabled);
    
    if (! enabled) {
      await cancelAllNotifications();
    }
  }

  Future<int> getReminderDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyReminderDays) ?? 3; // Default 3 hari sebelum
  }

  Future<void> setReminderDays(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyReminderDays, days);
  }

  Future<int> getReminderTimeHour() async {
    final prefs = await SharedPreferences. getInstance();
    return prefs.getInt(_keyReminderTime) ?? 8; // Default jam 8 pagi
  }

  Future<void> setReminderTimeHour(int hour) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyReminderTime, hour);
  }

  // NOTIFICATIONS 

  // Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert:  true,
      presentBadge: true,
      presentSound:  true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  // Schedule notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance:  Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert:  true,
      presentBadge: true,
      presentSound:  true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode. inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // EXPIRY CHECK 

  // Check and schedule notifications for expiring foods
  Future<void> checkAndScheduleExpiryNotifications(String userId) async {
    final enabled = await isNotificationEnabled();
    if (!enabled) return;

    final reminderDays = await getReminderDays();
    final reminderHour = await getReminderTimeHour();

    // Cancel existing notifications first
    await cancelAllNotifications();

    // Get all food items from Firestore
    final snapshot = await FirebaseFirestore.instance
        .collection('food_items')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'available')
        .get();

    final foods = snapshot.docs
        .map((doc) => FoodItemModel.fromFirestore(doc))
        .toList();

    int notificationId = 0;
    final List<FoodItemModel> expiringFoods = [];
    final List<FoodItemModel> expiredFoods = [];

    for (var food in foods) {
      if (food. daysUntilExpiry < 0) {
        // Sudah expired
        expiredFoods.add(food);
      } else if (food.daysUntilExpiry <= reminderDays) {
        // Akan expired dalam X hari
        expiringFoods.add(food);

        // Schedule notification untuk hari ini
        final now = DateTime.now();
        var scheduledDate = DateTime(
          now.year,
          now.month,
          now.day,
          reminderHour,
          0,
        );

        // Jika sudah lewat jam reminder hari ini, jadwalkan untuk besok
        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }

        await scheduleNotification(
          id: notificationId++,
          title: _getNotificationTitle(food. daysUntilExpiry),
          body: _getNotificationBody(food),
          scheduledDate: scheduledDate,
          payload: food. id,
        );
      }
    }

    // Show immediate notification jika ada yang sudah expired
    if (expiredFoods.isNotEmpty) {
      await showNotification(
        id: 9999,
        title: '⚠️ ${expiredFoods.length} Makanan Sudah Kadaluarsa! ',
        body: expiredFoods.map((f) => f.name).take(3).join(', ') +
            (expiredFoods.length > 3 ? ' dan lainnya' : ''),
      );
    }
  }

  String _getNotificationTitle(int daysUntilExpiry) {
    if (daysUntilExpiry == 0) {
      return '🚨 Kadaluarsa Hari Ini!';
    } else if (daysUntilExpiry == 1) {
      return '⚠️ Kadaluarsa Besok!';
    } else {
      return '📢 Kadaluarsa dalam $daysUntilExpiry hari';
    }
  }

  String _getNotificationBody(FoodItemModel food) {
    if (food.daysUntilExpiry == 0) {
      return '${food.name} akan kadaluarsa hari ini.  Segera gunakan!';
    } else if (food.daysUntilExpiry == 1) {
      return '${food.name} akan kadaluarsa besok. Jangan sampai terbuang!';
    } else {
      return '${food.name} akan kadaluarsa dalam ${food.daysUntilExpiry} hari. ';
    }
  }

  // Get summary of expiring foods
  Future<Map<String, dynamic>> getExpirySummary(String userId) async {
    final snapshot = await FirebaseFirestore. instance
        .collection('food_items')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'available')
        .get();

    final foods = snapshot.docs
        . map((doc) => FoodItemModel.fromFirestore(doc))
        .toList();

    int expiredCount = 0;
    int todayCount = 0;
    int soonCount = 0; // 1-3 hari

    for (var food in foods) {
      if (food.daysUntilExpiry < 0) {
        expiredCount++;
      } else if (food.daysUntilExpiry == 0) {
        todayCount++;
      } else if (food.daysUntilExpiry <= 3) {
        soonCount++;
      }
    }

    return {
      'expired': expiredCount,
      'today': todayCount,
      'soon': soonCount,
      'total': foods.length,
    };
  }
}