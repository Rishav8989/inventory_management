// home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management/pages/account_page.dart';
import 'package:inventory_management/pages/inventory_page.dart';
import 'package:inventory_management/pages/monitoring_page.dart';
import 'package:inventory_management/pages/support_page.dart';
import 'package:inventory_management/utils/translation/language_selector.dart';
import 'package:inventory_management/utils/translation/locale_controller.dart';
import 'package:inventory_management/widgets/bottom_navigation.dart';
import 'package:inventory_management/widgets/logout_button.dart';
import 'package:inventory_management/utils/theme/theme_switcher_buttons.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = const [
    MonitoringPage(),
    InventoryPage(),
    SupportPage(),
    AccountPage(),
  ];
  late LocaleController localeController;

  @override
  void initState() {
    super.initState();
    print("HomePage initState: Checking if LocaleController is registered...");
    try {
      localeController = Get.find<LocaleController>();
      print("HomePage initState: LocaleController FOUND!");
    } catch (e) {
      print("HomePage initState: LocaleController NOT NOT FOUND! Error: $e");
      rethrow;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(  // Directly define the AppBar here
        
        centerTitle: true,
        actions: <Widget>[
          const LanguageSelector(), // Keep using the LanguageSelector
          const SizedBox(width: 12),
          const ThemeToggleButton(), // Keep using the ThemeToggleButton
          const SizedBox(width: 12),
          const LogoutButton(),    // Keep using the LogoutButton
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: HomeBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}