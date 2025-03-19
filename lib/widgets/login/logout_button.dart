// logout_button.dart
import 'package:flutter/material.dart';
import 'package:inventory_management/pages/login_page.dart';
import 'package:inventory_management/main.dart';
import 'package:inventory_management/widgets/login/logout_confirmation_dialog.dart';
import 'package:get/get.dart'; // Import GetX

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton( // Removed Builder as GetX handles context implicitly
      icon: const Icon(Icons.logout),
      tooltip: 'Logout',
      onPressed: () async {
        // Use LogoutConfirmationDialog to get confirmation (no context needed now)
        bool? confirmLogout = await LogoutConfirmationDialog.show();

        if (confirmLogout == true) {
          pb.authStore.clear();
          print('Logged out from LogoutButton!');
          Get.offAll(() => const LoginPage()); // Use GetX navigation to LoginPage
        } else if (confirmLogout == false) {
          print('Logout cancelled from LogoutButton');
          Get.snackbar( // Use GetX Snackbar
            'Logout Cancelled', // Title of the snackbar
            'Logout process has been cancelled.', // Message of the snackbar
            snackPosition: SnackPosition.BOTTOM, // Position of the snackbar
            duration: const Duration(seconds: 2), // Duration the snackbar is shown
          );
        } else {
          print('Logout dialog dismissed without choice (LogoutButton)');
        }
      },
    );
  }
}