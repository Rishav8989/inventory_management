// login_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management/controller/auth_controller.dart';
import 'package:inventory_management/widgets/login/registration_page.dart'; // Import AuthController

class LoginPage extends GetView<AuthController> { // Use GetView and inject AuthController
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController _emailController = TextEditingController(text: 'temp@mail.com');
    final TextEditingController _passwordController = TextEditingController(text: 'Temp@mail');

    const double maxWidth = 400.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
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
                    controller: _emailController,
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
                    onFieldSubmitted: (value) {
                      if (_formKey.currentState!.validate()) {
                        controller.login(
                          _emailController.text,
                          _passwordController.text,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
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
                    onFieldSubmitted: (value) {
                      if (_formKey.currentState!.validate()) {
                        controller.login(
                          _emailController.text,
                          _passwordController.text,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: maxWidth,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          controller.login(
                            _emailController.text,
                            _passwordController.text,
                          );
                        }
                      },
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