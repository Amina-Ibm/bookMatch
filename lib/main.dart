import 'package:book_next/screens/searchBookScreen.dart';
import 'package:flutter/material.dart';
import 'models/book.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
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
        books.add(Book.fromJson(item));
      }
      setState(() {
        finalBooks = books;
      });
    } else {
      print('No books found for the search term.');
    }
  }
  Widget build(BuildContext context) {
    return searchBookScreen();

  }
}
