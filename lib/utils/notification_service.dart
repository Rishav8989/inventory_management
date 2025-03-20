import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart'; // Import permission_handler
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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

    // Request both storage & notification permissions
    await requestPermissions();
  }

  // Request Storage & Notification Permissions
  static Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.notification,
      Permission.storage,
    ].request();

    if (statuses[Permission.notification]!.isGranted) {
      print('✅ Notification permission granted.');
    } else {
      print('❌ Notification permission denied.');
    }

    if (statuses[Permission.storage]!.isGranted) {
      print('✅ Storage permission granted.');
    } else {
      print('❌ Storage permission denied.');
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

  // Save a test file (PDF, for example)
  static Future<void> saveTestFile() async {
    if (await Permission.storage.request().isGranted) {
      final downloadsDir = Directory('/storage/emulated/0/Download');
      final filePath = '${downloadsDir.path}/test_file.txt';

      final file = File(filePath);
      await file.writeAsString('This is a test file.');

      print('✅ File saved to: $filePath');
    } else {
      print('❌ Storage permission denied. Cannot save file.');
    }
  }
}
