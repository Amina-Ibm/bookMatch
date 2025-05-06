import 'package:appwrite/appwrite.dart';
import 'package:bookmatch/screens/homeView.dart';
import 'package:bookmatch/screens/mainScreen.dart';
import 'package:bookmatch/screens/onboardingScreen.dart';
import 'package:bookmatch/screens/readingListScreen.dart';
import 'package:bookmatch/screens/searchBookScreen.dart';
import 'package:bookmatch/screens/signUpScreen.dart';
import 'package:bookmatch/screens/signinScreen.dart';
import 'package:bookmatch/screens/splashScreen.dart';
import 'package:bookmatch/services/appwrite_service.dart';
import 'package:bookmatch/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'Controllers/BookListController.dart';
import 'Theme/appTheme.dart';
import 'models/book.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bookmatch/Controllers/ApiController.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(BookListController());
  Get.put(APIController());
  final SharedPreferences prefs = await SharedPreferences.getInstance();


  runApp(MainApp(prefs: prefs,));
}

class MainApp extends StatefulWidget {
  MainApp({super.key, required this.prefs});
  final SharedPreferences prefs;

  @override
  State<MainApp> createState() => _MainAppState();
}


class _MainAppState extends State<MainApp> {
  final String apiKey = 'AIzaSyBN-5o54DzX9NryLyOpm_mAf8jZMpcYpHo';
  final bookNameController = TextEditingController();
  final String maxTerms = '10';
  List<Book> finalBooks = [];
  final AuthService _authService = AuthService();

  Future<void> setOnboarding() async {
    widget.prefs.setBool('Onboarded', true);
  }
  Future<Widget> determineInitialScreen() async {
    bool isOnboarded = widget.prefs.getBool('Onboarded') == true;

    if (isOnboarded) {
      bool isAuthenticated = await _authService.isAuthenticated();
      if (isAuthenticated) {
        return mainScreen();
      } else {
        return const SignInScreen();
      }
    } else {
      return BookAppOnboarding(
        onFinish: () {
          setOnboarding();
          Get.to(() => const SignInScreen());
        },
      );
    }
  }


  ThemeData theme = ThemeData().copyWith(
    brightness: Brightness.light,
    primaryColor: Color(0xFF1956CF),
    textTheme: GoogleFonts.latoTextTheme().copyWith(
      displayLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white
      ),
      displayMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.white
      ),
      bodyMedium: TextStyle(
          fontSize: 16,
          color: Colors.black
      ),
      displaySmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black
      ),
    ),
    appBarTheme: AppBarTheme(
      //backgroundColor: colorScheme.primary,
      //backgroundColor: const Color(0xFF1956CF),
      titleTextStyle: GoogleFonts.latoTextTheme().displaySmall!.copyWith(
        fontSize: 24,
      ),
      //centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: const StadiumBorder(),
      ),
    ),
  );
  Widget build(BuildContext context) {

    return ToastificationWrapper(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen( onInitializationComplete: determineInitialScreen),
        theme: AppTheme.lightTheme,
      ),
    );
  }
}

