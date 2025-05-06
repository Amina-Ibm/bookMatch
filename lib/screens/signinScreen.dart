import 'package:bookmatch/Controllers/BookListController.dart';
import 'package:bookmatch/screens/mainScreen.dart';
import 'package:bookmatch/screens/searchBookScreen.dart';
import 'package:bookmatch/screens/signUpScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:bookmatch/services/auth_service.dart';
import 'package:appwrite/appwrite.dart';

import 'homeView.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  final AuthService auth = AuthService();
  final BookListController bookListController = Get.find();

  Future<void> signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      final currentUser = await auth.login(
          email: emailController.text,
          password: passwordController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign-in successful!')),
      );

        if (currentUser != null) {
          bookListController.userId = currentUser.$id;
          bookListController.update();
          Get.to(mainScreen());
      }
    } on AppwriteException catch (e) {
      String errorMessage = "An error occurred";
      if (e.code == 401) {
        errorMessage = "Invalid email or password";
      } else if (e.code == 429) {
        errorMessage = "Too many attempts, please try again later";
      } else {
        errorMessage = e.message ?? "Authentication failed";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  SizedBox(height: constraints.maxHeight * 0.1),
                  Image.asset(
                    'assets/images/applogo.jpg',
                    height: 100,
                  ),
                  SizedBox(height: constraints.maxHeight * 0.1),
                  Text(
                    "Sign In",
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  SizedBox(height: constraints.maxHeight * 0.05),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0 * 1.5, vertical: 16.0),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.all(Radius.circular(50)),
                            ),
                          ),
                          style: TextStyle(color: Colors.black),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty || !value.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16.0 * 1.5, vertical: 16.0),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.all(Radius.circular(50)),
                              ),
                            ),
                            style: TextStyle(color: Colors.black),
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                        ),
                        isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                          onPressed: signIn,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text("Sign in"),
                        ),
                        const SizedBox(height: 16.0),
                        TextButton(
                          onPressed: () {
                            // Add password reset logic
                          },
                          child: Text(
                            'Forgot Password?',
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.64),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.to(SignUpScreen()); // Navigate to sign-up screen
                          },
                          child: Text.rich(
                            TextSpan(
                              text: "Don’t have an account? ",
                              children: [
                                TextSpan(
                                  text: "Sign Up",
                                  style: TextStyle(color: Theme.of(context).primaryColor),
                                ),
                              ],
                            ),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
