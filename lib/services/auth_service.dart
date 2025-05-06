import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:bookmatch/Controllers/BookListController.dart';
import 'package:bookmatch/screens/mainScreen.dart';
import 'package:bookmatch/screens/signinScreen.dart';
import 'package:bookmatch/services/appwrite_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class AuthService {
  static const String endPoint = 'https://cloud.appwrite.io/v1';
  static const String projectId = '67f4f5e00020850f31e6';

  // Track active sessions
  static String? _currentSessionId;

  // Singleton pattern with reset capability
  static AuthService? _instance;

  static AuthService get instance {
    _instance ??= AuthService._internal();
    return _instance!;
  }

  static void resetInstance() {
    _instance = null;
    _currentSessionId = null;
  }

  factory AuthService() {
    return instance;
  }

  late final Client client;
  late final Account account;

  AuthService._internal() {
    _initializeClient();
  }

  void _initializeClient() {
    client = Client()
      ..setEndpoint(endPoint)
          .setProject(projectId);
    account = Account(client);
  }

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

      await login(email: email, password: password);
      return user;
    } on AppwriteException catch (e) {
      debugPrint('Error during sign up: ${e.message}');
      rethrow;
    }
  }

  Future<models.User> login({
    required String email,
    required String password,
  }) async {
    try {
      // First try to delete any existing sessions
      try {
        debugPrint("Attempting to delete existing session before login");
        await account.deleteSession(sessionId: 'current');
      } catch (e) {
        // It's okay if there's no session to delete
        debugPrint("No existing session to delete or couldn't delete: $e");
      }

      // Add a brief pause to ensure session deletion is processed
      await Future.delayed(Duration(milliseconds: 300));

      // Now attempt to create a new session
      debugPrint("Creating new session for $email");
      final session = await account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      // Store the session ID
      _currentSessionId = session.$id;

      // Add delay for session establishment
      await Future.delayed(Duration(milliseconds: 800));

      // Refresh AppwriteService to use the new session
      AppwriteService.resetClient();

      // Verify login
      final user = await account.get();
      debugPrint("Successfully logged in as $email (Session: ${_currentSessionId})");
      return user;
    } on AppwriteException catch (e) {
      debugPrint('Error during login: ${e.message}');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      if (_currentSessionId != null) {
        try {
          await account.deleteSession(sessionId: 'current');
          debugPrint('Successfully deleted session: $_currentSessionId');
          _currentSessionId = null;
        } catch (e) {
          debugPrint('Error during session deletion: $e');
        }
      }

      // Reset services
      AuthService.resetInstance();
      AppwriteService.resetClient();

      // Navigate to login screen
      Get.offAll(() => SignInScreen());
    } catch (e) {
      debugPrint('Error during logout process: $e');
    }
  }

  Future<bool> isAuthenticated() async {
    try {
      final user = await account.get();
      return user != null && _currentSessionId != null;
    } on AppwriteException catch (e) {
      debugPrint('Authentication check failed: ${e.message}');
      return false;
    }
  }

  Future<models.User?> getCurrentUser() async {
    try {
      final user = await account.get();
      return user;
    } on AppwriteException catch (e) {
      if (e.code == 401 || e.message?.contains('unauthorized') == true) {
        debugPrint('No authenticated session found');
        return null;
      }
      debugPrint('Error getting current user: ${e.message}');
      return null;
    }
  }

  Future<String?> getUserId() async {
    try {
      final user = await getCurrentUser();
      return user?.$id;
    } catch (e) {
      debugPrint('Error getting user ID: $e');
      return null;
    }
  }

  Future<bool> hasValidSession() async {
    try {
      final sessions = await account.listSessions();
      return sessions.sessions.isNotEmpty;
    } on AppwriteException catch (e) {
      debugPrint('Error checking sessions: ${e.message}');
      return false;
    }
  }

  Client getClient() => client;
}