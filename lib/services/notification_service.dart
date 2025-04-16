import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'dart:async';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Zaman dilimi verilerini başlat
    tz_data.initializeTimeZones();

    // Android için bildirim kanalı ayarları
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS için bildirim ayarları
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Bildirim ayarlarını başlat
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  // Günlük bildirim zamanlaması
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    // Şu anki zamanı al
    final now = DateTime.now();
    
    // Bugün için zamanlanacak saat ve dakika
    final scheduledDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );
    
    // Eğer belirtilen zaman geçmişse, bir sonraki gün için zamanla
    final effectiveDate = scheduledDateTime.isBefore(now)
        ? scheduledDateTime.add(const Duration(days: 1))
        : scheduledDateTime;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(effectiveDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'medicine_notification_channel',
          'İlaç Bildirimleri',
          channelDescription: 'İlaç hatırlatmaları için bildirim kanalı',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Düşük stok uyarısı bildirimi
  Future<void> showLowStockNotification({
    required int id,
    required String medicineName,
  }) async {
    await flutterLocalNotificationsPlugin.show(
      id,
      'Düşük İlaç Stoku Uyarısı',
      '$medicineName ilacından son 1 tane kaldı, ilacı yazdırmayı unutmayın!',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'low_stock_notification_channel',
          'Düşük Stok Uyarıları',
          channelDescription: 'Düşük ilaç stoku uyarıları için bildirim kanalı',
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.alarm,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // Tüm zamanlanmış bildirimleri iptal et
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // Belirli bir bildirimi iptal et
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
