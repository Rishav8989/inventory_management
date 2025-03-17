import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management/home_page.dart';
import 'package:inventory_management/registration_page.dart';
import 'main.dart'; // Import the global pb instance
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

// Create a GetX Controller for login functionality
class LoginController extends GetxController {
  final email = ''.obs;
  final password = ''.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final _formKey = GlobalKey<FormState>();

  Future<void> login() async {
    if (_formKey.currentState!.validate()) {
      isLoading.value = true;
      errorMessage.value = '';

      try {
        final authData = await pb.collection('users').authWithPassword(
              email.value.trim(),
              password.value.trim(),
            );

        // Login successful!
        print('Login successful!');
        print('Auth Store Valid: ${pb.authStore.isValid}');
        print('Auth Token: ${pb.authStore.token}');
        print(
            'User ID: ${pb.authStore.record?.id}'); // Use ?. to avoid null access error if record is null

        // Store the token in cache
        await _storeToken(pb.authStore.token);

        // Navigate to the home page
        Get.offAll(const HomePage());
      } catch (e) {
        // Catch ANY error for now - simplified error handling
        print('Login Error: $e'); // Print the full error to console for debugging
        errorMessage.value =
            'Login failed. Please check your credentials and try again.'; // Basic error message
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pb_auth_token', token);
    print('Token stored in cache');
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    final double maxWidth = 400.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: controller._formKey,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Obx(() {
                    if (controller.errorMessage.value.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          controller.errorMessage.value,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: TextFormField(
                      controller: TextEditingController(text: controller.email.value),
                      onChanged: (value) => controller.email.value = value,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email or Username',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email or username';
                        }
                        return null;
                      },
                      onFieldSubmitted: (value) => controller.login(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: TextFormField(
                      controller: TextEditingController(text: controller.password.value),
                      onChanged: (value) => controller.password.value = value,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                      onFieldSubmitted: (value) => controller.login(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.login,
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Text('Login'),
                    )),
                  ),
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: TextButton(
                      onPressed: () {
                        // Navigate to registration page (correct navigation using Navigator.push)
                        Get.to(const RegistrationPage());
                      },
                      child: const Text('Don\'t have an account? Register'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}