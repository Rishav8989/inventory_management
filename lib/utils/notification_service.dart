import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart'; // Import permission_handler
import 'dart:io';
import 'package:flutter/foundation.dart'; // Import foundation for kIsWeb

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize Notification Settings
  static Future<void> initialize() async {
    AndroidInitializationSettings androidSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher'); // Use your launcher icon

    DarwinInitializationSettings iosSettings =
        const DarwinInitializationSettings();

    LinuxInitializationSettings linuxSettings =
        const LinuxInitializationSettings(defaultActionName: 'Open notification');

    InitializationSettings settings;

    if (Platform.isAndroid) {
      settings = InitializationSettings(android: androidSettings);
    } else if (Platform.isIOS || Platform.isMacOS) { // macOS is also Darwin based
      settings = InitializationSettings(iOS: iosSettings);
    } else if (Platform.isLinux) {
      settings = InitializationSettings(linux: linuxSettings);
    } else {
      settings = InitializationSettings(android: androidSettings); // Default to Android if platform is unknown, or handle as needed
    }

    await _notificationsPlugin.initialize(
      settings,
    );

    // Request permissions only on Android
    if (Platform.isAndroid) {
      await requestPermissions();
    } else {
      if (kDebugMode) {
        print("Permissions request skipped as not on Android platform.");
      }
    }
  }

  // Request Storage & Notification Permissions - Android Only
  static Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.notification,
        Permission.notification, // Corrected typo - should be Permission.storage if you need storage too
      ].request();

      if (statuses[Permission.notification]!.isGranted) {
        if (kDebugMode) {
          print('✅ Notification permission granted.');
        }
      } else {
        if (kDebugMode) {
          print('❌ Notification permission denied.');
        }
      }

      if (statuses[Permission.storage] != null && statuses[Permission.storage]!.isGranted) { // Check for null before accessing
        if (kDebugMode) {
          print('✅ Storage permission granted.');
        }
      } else {
        if (kDebugMode) {
          print('❌ Storage permission denied.');
        }
      }
    } else {
      if (kDebugMode) {
        print("Permission request function called but not on Android platform. Permissions are relevant only for Android in this function.");
      }
    }
  }

  // Show Notification - Platform Agnostic (should work on Android & iOS, Linux)
  static Future<void> showNotification(String title, String body) async {
    AndroidNotificationDetails androidDetails = const AndroidNotificationDetails(
      'default_channel', // Replace with a more specific channel ID if needed
      'Default Channel', // Replace with a user-friendly channel name
      importance: Importance.high,
      priority: Priority.high,
    );

    DarwinNotificationDetails iosDetails = const DarwinNotificationDetails();
    LinuxNotificationDetails linuxDetails = const LinuxNotificationDetails(
      category: LinuxNotificationCategory.device,
    );

    NotificationDetails details;

    if (Platform.isAndroid) {
      details = NotificationDetails(android: androidDetails);
    } else if (Platform.isIOS || Platform.isMacOS) {
      details = NotificationDetails(iOS: iosDetails);
    } else if (Platform.isLinux) {
      details = NotificationDetails(linux: linuxDetails);
    } else {
      details = NotificationDetails(android: androidDetails); // Default to Android if platform is unknown
    }

    if (kDebugMode) {
      // Debugging: Print the category value and its type
      print("Notification Category Value: ${linuxDetails.category}");
      print("Notification Category Value Type: ${linuxDetails.category.runtimeType}");
    }

    await _notificationsPlugin.show(
      0, // Notification ID - keep it 0 to overwrite previous if needed
      title,
      body,
      details,
    );
  }

  // Save a test file (PDF, for example) - Android Only with Storage Permission
  static Future<void> saveTestFile() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) {
        final downloadsDir = Directory('/storage/emulated/0/Download'); // Android specific path
        final filePath = '${downloadsDir.path}/test_file.txt';

        final file = File(filePath);
        await file.writeAsString('This is a test file.');

        if (kDebugMode) {
          print('✅ File saved to: $filePath');
        }
      } else {
        if (kDebugMode) {
          print('❌ Storage permission denied. Cannot save file.');
        }
      }
    } else {
      if (kDebugMode) {
        print("Save file function called but not on Android platform. File saving with storage permissions is relevant only for Android in this function.");
      }
    }
  }
}