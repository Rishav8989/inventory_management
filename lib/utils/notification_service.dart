import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart'; // Import permission_handler

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize Notification Settings
  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // Use your launcher icon

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
    );
  }

  // Request Notification Permissions
  static Future<void> requestNotificationPermissions() async {
    PermissionStatus status = await Permission.notification.status;
    if (!status.isGranted) {
      status = await Permission.notification.request();
      if (status.isGranted) {
        print('Notification permissions granted.');
      } else {
        print('Notification permissions denied.');
      }
    } else {
      print('Notification permissions already granted.');
    }
  }

  // Show Notification
  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'default_channel', // Replace with a more specific channel ID if needed
      'Default Channel', // Replace with a user-friendly channel name
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      0, // Notification ID - keep it 0 to overwrite previous if needed
      title,
      body,
      details,
    );
  }
}