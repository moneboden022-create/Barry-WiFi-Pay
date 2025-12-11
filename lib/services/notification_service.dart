// lib/services/notification_service.dart
// 🔔 BARRY WI-FI - Service de Notifications 5G

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ------------------------------------------------------
  // 1️⃣ INITIALISATION (Multi-plateforme)
  // ------------------------------------------------------
  static Future<void> init() async {
    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const LinuxInitializationSettings linuxSettings =
          LinuxInitializationSettings(
        defaultActionName: 'Open notification',
      );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: iosSettings,
        linux: linuxSettings,
      );

      await _plugin.initialize(settings);
    } catch (e) {
      // Ignore errors on platforms that don't support notifications
      if (kIsWeb) return;
    }
  }

  // ------------------------------------------------------
  // 2️⃣ DEMANDER PERMISSION ANDROID 13+
  // ------------------------------------------------------
  static Future<void> requestPermission() async {
    final androidImplementation =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // Note: requestNotificationsPermission est la méthode correcte
    await androidImplementation?.requestNotificationsPermission();
  }

  // ------------------------------------------------------
  // 3️⃣ NOTIFICATION SIMPLE
  // ------------------------------------------------------
  static Future<void> show(String title, String body) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'wifi_channel',            // ID du channel
        'BARRY WIFI Notifications', // Nom du channel
        importance: Importance.high,
        priority: Priority.high,
      );

      const DarwinNotificationDetails darwinDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const LinuxNotificationDetails linuxDetails = LinuxNotificationDetails(
        urgency: LinuxNotificationUrgency.normal,
      );

      final NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
        linux: linuxDetails,
      );

      await _plugin.show(
        DateTime.now().millisecondsSinceEpoch % 100000, // ID unique
        title,
        body,
        platformDetails,
      );
    } catch (e) {
      // Ignore errors on platforms that don't support notifications
      if (kIsWeb) return;
    }
  }

  // ------------------------------------------------------
  // 4️⃣ NOTIFICATION AVEC ACTION
  // ------------------------------------------------------
  static Future<void> showWithPayload(
    String title,
    String body,
    String payload,
  ) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'wifi_channel',
        'BARRY WIFI Notifications',
        importance: Importance.high,
        priority: Priority.high,
      );

      const DarwinNotificationDetails darwinDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const LinuxNotificationDetails linuxDetails = LinuxNotificationDetails(
        urgency: LinuxNotificationUrgency.normal,
      );

      final NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
        linux: linuxDetails,
      );

      await _plugin.show(
        DateTime.now().millisecondsSinceEpoch % 100000,
        title,
        body,
        platformDetails,
        payload: payload,
      );
    } catch (e) {
      // Ignore errors on platforms that don't support notifications
      if (kIsWeb) return;
    }
  }

  // ------------------------------------------------------
  // 5️⃣ ANNULER TOUTES LES NOTIFICATIONS
  // ------------------------------------------------------
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
