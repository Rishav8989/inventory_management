import 'package:flutter/material.dart';
import 'package:inventory_management/home_page.dart';
import 'package:inventory_management/login_page.dart';
import 'package:inventory_management/main.dart'; // Assuming pb is defined here
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocketbase/pocketbase.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  Future<(String?, String?)> _getCachedAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('pb_auth_token');
    final userId = prefs.getString('pb_user_id');
    return (token, userId);
  }

  Future<void> _loadCachedAuth() async {
    final (cachedToken, cachedUserId) = await _getCachedAuth();
    if (cachedToken != null && cachedUserId != null) {
      // Create a RecordModel from the map.
      final record = RecordModel.fromJson({'id': cachedUserId});

      pb.authStore.save(cachedToken, record);
      print('Cached token and user ID loaded.');
      print('Cached User ID: $cachedUserId'); // Print the cached user ID
    } else {
      print('No cached token or user ID found.');
    }
  }

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await _loadCachedAuth();

    if (pb.authStore.isValid) {
      print(
          'User is already logged in (Token: ${pb.authStore.token}, ID: ${pb.authStore.record?.id})');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      print('User is not logged in.');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// --- In your LoginPage (or wherever you handle successful login) ---

Future<void> _handleLogin(BuildContext context, String email, String password) async {
  try {
    final authData = await pb.collection('users').authWithPassword(email, password);

    // Store BOTH token and user ID on successful login
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pb_auth_token', pb.authStore.token);
    await prefs.setString('pb_user_id', pb.authStore.record!.id);

    print('Logged in User ID: ${pb.authStore.record!.id}'); // Print after login

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const HomePage()));
  } catch (e) {
    print('Login error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login failed: $e')),
    );
  }
}

// --- Logout (example) ---

Future<void> _handleLogout(BuildContext context) async {
  pb.authStore.clear();

  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('pb_auth_token');
  await prefs.remove('pb_user_id');

  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => const LoginPage()));
}