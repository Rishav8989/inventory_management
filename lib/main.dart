// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; // Import GetStorage
import 'package:inventory_management/utils/theme/app_theme.dart';
import 'package:inventory_management/utils/theme/theme_controller.dart';
import 'package:inventory_management/utils/translation/locale_controller.dart';
import 'package:inventory_management/utils/translation/translation_service.dart';
import 'package:inventory_management/utils/auth/auth_check.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:inventory_management/utils/notification_service.dart'; // Import Notification Service

late PocketBase pb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize GetStorage - IMPORTANT
  await GetStorage.init();

  // ✅ Load environment variables before initializing PocketBase
  await dotenv.load(fileName: ".env");

  // ✅ Initialize ThemeController
  final ThemeController themeController = Get.put(ThemeController());
  await themeController.loadInitialTheme();

  // ✅ Initialize LocaleController
  final LocaleController localeController = Get.put(LocaleController());

  // ✅ Initialize PocketBase with fallback URL
  pb = PocketBase(dotenv.env['POCKETBASE_URL'] ?? 'https://default.url');

  // ✅ Initialize and request permissions for notifications & storage
  await NotificationService.initialize();
  await NotificationService.requestPermissions(); // Merged permission requests here!

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final LocaleController localeController = Get.find<LocaleController>();

    return Obx(() => GetMaterialApp(
          title: 'Flutter Notes App'.tr,
          translations: TranslationService(),
          locale: localeController.currentLocale,
          fallbackLocale: TranslationService.fallbackLocale,
          theme: themeController.themeData,
          darkTheme: darkTheme,
          themeMode: themeController.themeMode,
          debugShowCheckedModeBanner: false,
          home: const AuthCheck(),
        ));
  }
}
