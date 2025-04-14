import 'package:bookmatch/screens/mainScreen.dart';
import 'package:bookmatch/screens/readingListScreen.dart';
import 'package:bookmatch/screens/searchBookScreen.dart';
import 'package:bookmatch/screens/signinScreen.dart';
import 'package:flutter/material.dart';
import 'models/book.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Open the Hive box
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}


class _MainAppState extends State<MainApp> {
  final String apiKey = 'AIzaSyBN-5o54DzX9NryLyOpm_mAf8jZMpcYpHo';
  final bookNameController = TextEditingController();
  final String maxTerms = '10';
  List<Book> finalBooks = [];

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
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignInScreen(),
      theme: theme
    );
  }
}
