// main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management/pages/login_page.dart';
import 'package:inventory_management/utils/theme/app_theme.dart';
import 'package:inventory_management/utils/theme/theme_controller.dart';
import 'package:inventory_management/utils/translation/locale_controller.dart';
import 'package:inventory_management/utils/translation/translation_service.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:inventory_management/utils/auth/auth_check.dart'; // UPDATED import

final pb = PocketBase('https://first.pockethost.io/');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ThemeController themeController = Get.put(ThemeController());
  await themeController.loadInitialTheme();
  final LocaleController localeController = Get.put(LocaleController());
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