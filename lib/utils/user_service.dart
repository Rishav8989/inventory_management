// lib/user_service.dart

import 'package:inventory_management/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocketbase/pocketbase.dart';

class UserService {
  static const String _userIdKey = 'pb_user_id';
  static const String _authTokenKey = 'pb_auth_token';

  // Method to get the user ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Method to set the user ID
  Future<void> setUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  // Method to clear the user ID
  Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }

  // Method to get the auth token
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  // Method to set the auth token
  Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  // Method to clear the auth token
  Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
  }

  // Method to handle user login
  Future<void> login(String email, String password) async {
    try {
      final authData = await pb.collection('users').authWithPassword(email, password);
      await setAuthToken(pb.authStore.token);
      await setUserId(pb.authStore.record!.id);
      print('Logged in User ID: ${pb.authStore.record!.id}');
    } catch (e) {
      print('Login error: $e');
      throw e; // Rethrow the error for handling in the UI
    }
  }

 
}
