// lib/widgets/bottom_navigation.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const HomeBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard_customize_outlined), // Choose appropriate icons
          label: 'Dashboard'.tr, // Translate Bottom Navigation labels
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.inventory_rounded),
          label: 'Inventory'.tr, // Translate Bottom Navigation labels
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.assignment_add),
          label: 'Order'.tr, // Translate Bottom Navigation labels
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.account_circle),
          label: 'Account'.tr, // Translate Bottom Navigation labels
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: Colors.blue, // Customize selected item color
      unselectedItemColor: Colors.grey, // Customize unselected item color
      onTap: onItemTapped,
      type: BottomNavigationBarType.fixed, // To show labels for all items
    );
  }
}