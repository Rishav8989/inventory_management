import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management/controller/home_controller.dart';
import 'package:inventory_management/pages/account/select_language.dart';
import 'package:inventory_management/utils/translation/language_selector.dart';
import 'package:inventory_management/utils/theme/theme_switcher_buttons.dart';
import 'package:inventory_management/widgets/bottom_navigation.dart';
import 'package:inventory_management/widgets/login/logout_button.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: <Widget>[
          const ThemeToggleButton(),
          const SizedBox(width: 12),
        ],
      ),
      body: Obx(
        () => IndexedStack(
          index: controller.selectedIndex.value,
          children: controller.pages,
        ),
      ),
      bottomNavigationBar: Obx(
        () => HomeBottomNavigation(
          selectedIndex: controller.selectedIndex.value,
          onItemTapped: controller.onItemTapped,
        ),
      ),
    );
  }
}
