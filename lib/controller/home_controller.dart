import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management/pages/account_page.dart';
import 'package:inventory_management/pages/inventory/inventory_page.dart';
import 'package:inventory_management/pages/dashboard/dashboard_page.dart';
import 'package:inventory_management/pages/orders/order_page.dart';
import 'package:inventory_management/utils/translation/locale_controller.dart';

class HomeController extends GetxController {
  var selectedIndex = 0.obs;

  final List<Widget> pages = [
    InventoryDashboardPage(),
    InventoryPage(),
    CreateOrderPage(),
    AccountPage(),
  ];

  late LocaleController localeController;

  @override
  void onInit() {
    super.onInit();
    print("HomeController: Checking if LocaleController is registered...");
    try {
      localeController = Get.find<LocaleController>();
      print("HomeController: LocaleController FOUND!");
    } catch (e) {
      print("HomeController: LocaleController NOT FOUND! Error: $e");
      rethrow;
    }
  }

  void onItemTapped(int index) {
    selectedIndex.value = index;
  }
}
