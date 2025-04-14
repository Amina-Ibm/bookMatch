import 'package:bookmatch/screens/signinScreen.dart';
import 'package:flutter/material.dart';
import 'package:bookmatch/services/auth_service.dart';
import 'package:appwrite/appwrite.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;

  final AuthService auth = AuthService();

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await auth.signUp(email: emailController.text,
          password: passwordController.text,
          name: nameController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign-up successful! Please Log in.')),
      );
      Get.off(() => const SignInScreen());
    } on AppwriteException catch (e) {
      String errorMessage = "An error occurred";
      if (e.code == 409) {
        errorMessage = "Email already in use";
      } else if (e.code == 400) {
        errorMessage = "Wrong format of email or password";
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Image.asset('assets/images/applogo.jpg', height: 100),
              const SizedBox(height: 30),
              Text("Sign Up",
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration:  InputDecoration(
                        hintText: 'Full Name',
                        fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.1), // Change to match SignInScreen
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0 * 1.5, vertical: 16.0),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                      ),
                      style: TextStyle(color: Colors.black),
                      validator: (value) => value!.isEmpty ? 'Enter your full name' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0 * 1.5, vertical: 16.0),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                      ),
                      style: TextStyle(color: Colors.black),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value!.contains('@') ? null : 'Enter a valid email',
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0 * 1.5, vertical: 16.0),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                      ),
                      style: TextStyle(color: Colors.black),
                      validator: (value) => value!.length >= 6 ? null : 'Password must be at least 6 characters',
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0 * 1.5, vertical: 16.0),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                      ),
                      style: TextStyle(color: Colors.black),
                      validator: (value) => value == passwordController.text ? null : 'Passwords do not match',
                    ),
                    const SizedBox(height: 20),
                    isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: signUp,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Theme.of(context).colorScheme.primary, // Match SignIn button color
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: const StadiumBorder(),
                        ),
                      child: const Text("Sign Up"),
                    ),
                    const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Get.to(SignInScreen()); // Navigate to sign-up screen
                    },
                    child: Text.rich(
                      TextSpan(
                        text: "Already have an account? ",
                        children: [
                          TextSpan(
                            text: "Sign In",
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
        ),
      ),
    );
  }
}
