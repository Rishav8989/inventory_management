import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LogoutConfirmationDialog {
  static Future<bool?> show() async {
    return Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Get.back(result: false), // Cancel returns false using Get.back
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),  // Logout returns true using Get.back
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}