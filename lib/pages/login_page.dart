// login_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management/controller/auth_controller.dart';
import 'package:inventory_management/widgets/login/registration_page.dart'; // Import AuthController

class LoginPage extends GetView<AuthController> { // Use GetView and inject AuthController
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController emailController = TextEditingController(text: 'temp@mail.com');
    final TextEditingController passwordController = TextEditingController(text: 'Temp@mail');

    const double maxWidth = 400.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxWidth),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Obx(() => controller.errorMessage.value.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            controller.errorMessage.value,
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                      : const SizedBox.shrink()),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email or Username',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder( // Add rounded border
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email or username';
                      }
                      return null;
                    },
                    onFieldSubmitted: (value) {
                      if (formKey.currentState!.validate()) {
                        controller.login(
                          emailController.text,
                          passwordController.text,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder( // Add rounded border
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    onFieldSubmitted: (value) {
                      if (formKey.currentState!.validate()) {
                        controller.login(
                          emailController.text,
                          passwordController.text,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: maxWidth,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          controller.login(
                            emailController.text,
                            passwordController.text,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom( // Add rounded border to button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Obx(() => controller.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Text('Login')),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    // Added to wrap TextButton
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: TextButton(
                      onPressed: () {
                        // Navigate to registration page using GetX
                        Get.to(() => const RegistrationPage());
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