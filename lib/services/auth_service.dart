import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:bookmatch/screens/mainScreen.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class AuthService {
  // Appwrite constants
  static const String endPoint = 'https://cloud.appwrite.io/v1';
  static const String projectId = '67f4f5e00020850f31e6';

  // Initialize Appwrite client
  final Client client = Client();
  late final Account account;

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal() {
    // Initialize the client
    client
        .setEndpoint(endPoint)
        .setProject(projectId);

    account = Account(client);
  }

  // Get current user
  Future<models.User?> getCurrentUser() async {
    try {
      final user = await account.get();
      return user;
    } on AppwriteException catch (e) {
      debugPrint('Error getting current user: ${e.message}');
      return null;
    }
  }

  // Sign up with email and password
  Future<models.User?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final user = await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );

      // After sign up, you might want to log in the user automatically
      await login(email: email, password: password);

      return user;
    } on AppwriteException catch (e) {
      debugPrint('Error during sign up: ${e.message}');
      rethrow;
    }
  }

  // Login with email and password
  Future<models.Session> login({
    required String email,
    required String password,
  }) async {
    final currentUser = await getCurrentUser();
    if (currentUser != null) {
      debugPrint("User already logged in as ${currentUser.email}");
      // You could redirect the user to home here instead of retrying login
      Get.to(mainScreen());
    }



    try {
      final session = await account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      return session;
    } on AppwriteException catch (e) {
      debugPrint('Error during login: ${e.message}');
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await account.deleteSession(sessionId: 'current');
    } on AppwriteException catch (e) {
      debugPrint('Error during logout: ${e.message}');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      await account.createRecovery(
        email: email,
        url: 'https://your-app-url.com/reset-password', // URL to your reset password page
      );
    } on AppwriteException catch (e) {
      debugPrint('Error during password reset: ${e.message}');
      rethrow;
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      await account.get();
      return true;
    } catch (e) {
      return false;
    }
  }
  Client getClient() => client;

}