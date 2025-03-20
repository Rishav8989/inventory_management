import 'package:get/get.dart';
import 'package:inventory_management/main.dart';
import 'package:inventory_management/pages/login_page.dart';
import 'package:inventory_management/widgets/login/logout_confirmation_dialog.dart';

class LogoutService {
  static Future<void> performLogout() async {
    bool? confirmLogout = await LogoutConfirmationDialog.show();

    if (confirmLogout == true) {
      pb.authStore.clear();
      print('Logged out successfully!');
      Get.offAll(() => const LoginPage());
    } else if (confirmLogout == false) {
      print('Logout cancelled');
      Get.snackbar(
        'Logout cancelled',
        'Logout action was cancelled',
        duration: const Duration(seconds: 2),
      );
    } else {
      print('Logout dialog dismissed without choice');
    }
  }
}
