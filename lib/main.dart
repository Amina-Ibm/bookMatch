import 'package:bookmatch/screens/mainScreen.dart';
import 'package:bookmatch/screens/readingListScreen.dart';
import 'package:bookmatch/screens/searchBookScreen.dart';
import 'package:flutter/material.dart';
import 'models/book.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  Future<void> searchBook() async {
    List<Book> books = [];
    final searchTerm = bookNameController.text;
    final url = Uri.https('www.googleapis.com', '/books/v1/volumes', {'q': searchTerm, 'limit' : maxTerms, 'key': apiKey},);
    final Map<String, String> headers = {
      'Content-Type' : 'application/json'
    };
    final response = await http.get(url,
        headers: headers);
    print(response.body);
    final fetchedData = jsonDecode(response.body);

    if (fetchedData != null && fetchedData['items'] != null) {

      for (var item in fetchedData['items']) {
        books.add(Book.fromJsonWithGoogleApi(item));
      }
      setState(() {
        finalBooks = books;
      });
    } else {
      print('No books found for the search term.');
    }
  }
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: mainScreen(),
    );
  }
}
