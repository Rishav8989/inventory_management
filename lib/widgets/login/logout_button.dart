// logout_button.dart
import 'package:flutter/material.dart';
import 'package:inventory_management/pages/login_page.dart';
import 'package:inventory_management/main.dart';
import 'package:inventory_management/widgets/login/logout_confirmation_dialog.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder( // Wrap IconButton in Builder to get a fresh context for SnackBar
      builder: (BuildContext appBarContext) => IconButton(
        icon: const Icon(Icons.logout),
        tooltip: 'Logout',
        onPressed: () async {
          // Use LogoutConfirmationDialog to get confirmation
          bool? confirmLogout = await LogoutConfirmationDialog.show(context);

          if (confirmLogout == true) {
            pb.authStore.clear();
            print('Logged out from LogoutButton!');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          } else if (confirmLogout == false) {
            print('Logout cancelled from LogoutButton');
            ScaffoldMessenger.of(appBarContext).showSnackBar( // Use appBarContext for SnackBar
              const SnackBar(
                content: Text('Logout cancelled'),
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            print('Logout dialog dismissed without choice (LogoutButton)');
          }
        },
      ),
    );
  }
}