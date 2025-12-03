// lib/services/notification_service.dart
// 🔔 BARRY WI-FI - Service de Notifications 5G

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ------------------------------------------------------
  // 1️⃣ INITIALISATION (Android + iOS)
  // ------------------------------------------------------
  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: DarwinInitializationSettings(),
    );

    await _plugin.initialize(settings);
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
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'wifi_channel',            // ID du channel
      'BARRY WIFI Notifications', // Nom du channel
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _plugin.show(
      DateTime.now().millisecond, // ID unique
      title,
      body,
      platformDetails,
    );
  }

  // ------------------------------------------------------
  // 4️⃣ NOTIFICATION AVEC ACTION
  // ------------------------------------------------------
  static Future<void> showWithPayload(
    String title,
    String body,
    String payload,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'wifi_channel',
      'BARRY WIFI Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _plugin.show(
      DateTime.now().millisecond,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  // ------------------------------------------------------
  // 5️⃣ ANNULER TOUTES LES NOTIFICATIONS
  // ------------------------------------------------------
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
