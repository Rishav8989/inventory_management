// auth_controller.dart
import 'package:get/get.dart';
import 'package:inventory_management/main.dart'; // Adjust path if necessary
import 'package:inventory_management/pages/home_page.dart'; // Adjust path if necessary
import 'package:inventory_management/pages/login_page.dart'; // Adjust path if necessary
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final userId = RxnString(); // Reactive User ID (nullable String)
  final isLoggedIn = false.obs; // Reactive login status
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuth(); // Check auth on controller initialization
  }

  Future<String?> _getCachedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('pb_auth_token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pb_auth_token', token);
    print('Token saved: $token');
  }

  Future<String?> _getCachedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('pb_user_id');
  }

  Future<void> _saveUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pb_user_id', id);
    print('User ID saved: $id');
  }

  Future<void> _loadCachedToken() async {
    final cachedToken = await _getCachedToken();
    if (cachedToken != null) {
      pb.authStore.save(cachedToken, pb.authStore.record);
      print('Cached token loaded: $cachedToken');
    } else {
      print('No cached token found.');
    }
  }

  Future<void> _loadCachedUserId() async {
    final cachedUserId = await _getCachedUserId();
    if (cachedUserId != null) {
      userId.value = cachedUserId; // Set User ID from cache
      print('Cached User ID loaded: $cachedUserId');
    } else {
      print('No cached User ID found.');
    }
  }

  Future<void> checkAuth() async {
    await _loadCachedToken();
    await _loadCachedUserId(); // Load cached User ID
    if (pb.authStore.isValid) {
      print('User is already logged in (Token: ${pb.authStore.token})');
      if (userId.value == null) {
        userId.value = pb.authStore.record?.id; // Set User ID if not loaded from cache yet (fallback)
        _saveUserId(userId.value!); // Ensure User ID is saved if it wasn't cached before
      }
      isLoggedIn.value = true;
      Get.offAll(() => HomePage()); // Use GetX navigation
    } else {
      isLoggedIn.value = false;
      Get.offAll(() => const LoginPage()); // Use GetX navigation
    }
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await pb.collection('users').authWithPassword(
        email.trim(),
        password.trim(),
      );

      print('Login successful!');
      print('Auth Store Valid: ${pb.authStore.isValid}');
      print('Auth Token: ${pb.authStore.token}');
      print('User ID: ${pb.authStore.record?.id}');

      userId.value = pb.authStore.record?.id; // Set User ID in controller
      isLoggedIn.value = true;
      await _saveToken(pb.authStore.token); // Save token
      await _saveUserId(userId.value!); // Save User ID to cache
      Get.offAll(() => HomePage()); // Use GetX navigation
    } catch (e) {
      print('Login Error: $e');
      errorMessage.value = 'Login failed. Please check your credentials and try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    pb.authStore.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pb_auth_token');
    await prefs.remove('pb_user_id'); // Remove User ID from cache on logout
    userId.value = null;
    isLoggedIn.value = false;
    Get.offAll(() => const LoginPage()); // Navigate to LoginPage after logout
  }
}