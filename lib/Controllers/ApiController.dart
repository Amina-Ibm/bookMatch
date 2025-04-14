import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import '../screens/bookDetailScreen.dart';
import 'package:flutter/material.dart';

class APIController extends GetxController {
  final String apiKey = 'AIzaSyBN-5o54DzX9NryLyOpm_mAf8jZMpcYpHo';
  final int maxTerms = 10;
  RxList<Book> finalBooks = <Book>[].obs;
  RxBool hasNavigated = false.obs;
  RxBool isLoading = false.obs;

  Future<void> searchBook(String searchQuery) async {
    final searchTerm = searchQuery;
    final url = Uri.https('www.googleapis.com', '/books/v1/volumes', {
      'q': searchTerm,
      'maxResults': maxTerms.toString(),
      'key': apiKey,
    });

    try {
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});
      final fetchedData = jsonDecode(response.body);

      if (fetchedData != null && fetchedData['items'] != null) {
        final books = fetchedData['items'].map<Book>((item) => Book.fromJsonWithGoogleApi(item)).toList();
        finalBooks.assignAll(books);
      } else {
        print('No books found for the search term.');
      }
    } catch (e) {
      print('Error fetching books: $e');
    }
  }
  Future<Book> searchBookByAI(String searchQuery) async {
    final searchTerm = searchQuery;
    final url = Uri.https('www.googleapis.com', '/books/v1/volumes', {
      'q': searchTerm,
      'maxResults': '1',
      'key': apiKey,
    });

    try {
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});
      final fetchedData = jsonDecode(response.body);

      if (fetchedData != null && fetchedData['items'] != null) {
        return Book.fromJsonWithGoogleApi(fetchedData['items'][0]); // Return book if found
      } else {
        throw Exception('No book found for "$searchQuery".'); // Throw exception instead of returning null
      }
    } catch (e) {
      throw Exception('Error fetching book: $e'); // Ensure function always returns something
    }
  }

  Future<void> searchBooksByAIRecommendations(List<String> bookTitles) async {
    //isLoading.value = true;
    List<Book> finalBookList = []; // New list to store one book per AI recommendation
    finalBooks.clear();
    for (var title in bookTitles) {
      final book = await searchBookByAI(title); // Fetch books from Google Books API
      finalBookList.add(book);
      }
    finalBooks.addAll(finalBookList);
    isLoading.value = false;
    }// Return the final list of books
  }
