import 'dart:convert';
import 'package:bookmatch/Controllers/BookListController.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import '../screens/bookDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:bookmatch/services/appwrite_service.dart';
import 'package:appwrite/appwrite.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'BookListController.dart';

class APIController extends GetxController {
  final String apiKey = 'AIzaSyBN-5o54DzX9NryLyOpm_mAf8jZMpcYpHo';
  final int maxTerms = 10;
  RxList<Book> searchedBooks = <Book>[].obs;
  final RxList<Book> userRecBooks = <Book>[].obs;
  final RxList<Book> trendingBooks = <Book>[].obs;
  final RxList<Book> contentRecBooks = <Book>[].obs;
  RxBool isUserRecsLoading = false.obs;
  RxBool isContentRecsLoading = false.obs;
  RxBool hasNavigated = false.obs;
  RxBool isSearchLoading = false.obs;
  RxBool isTrendingLoading = false.obs;
  final AppwriteService _appwriteService = AppwriteService();
  final BookListController bookController = Get.find();

@override
  void dispose(){
    super.dispose();
  searchedBooks.clear();
  userRecBooks.clear();
  print("dispose method working");
  trendingBooks.clear();
  contentRecBooks.clear();
}
  Future<void> searchBook(String searchQuery) async {
    final searchTerm = searchQuery;
    final url = Uri.https('www.googleapis.com', '/books/v1/volumes', {
      'q': searchTerm,
      'maxResults': maxTerms.toString(),
      'key': apiKey,
    });

    try {
      isSearchLoading.value = true;
      final response = await http.get(
          url, headers: {'Content-Type': 'application/json'});
      final fetchedData = jsonDecode(response.body);

      if (fetchedData != null && fetchedData['items'] != null) {
        final books = fetchedData['items'].map<Book>((item) =>
            Book.fromJsonWithGoogleApi(item)).toList();
        searchedBooks.assignAll(books);
        isSearchLoading.value = false;
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
      final response = await http.get(
          url, headers: {'Content-Type': 'application/json'});
      final fetchedData = jsonDecode(response.body);

      if (fetchedData != null && fetchedData['items'] != null) {
        return Book.fromJsonWithGoogleApi(
            fetchedData['items'][0]); // Return book if found
      } else {
        throw Exception(
            'No book found for "$searchQuery".'); // Throw exception instead of returning null
      }
    } catch (e) {
      throw Exception(
          'Error fetching book: $e'); // Ensure function always returns something
    }
  }

  Future<void> searchBooksByAIRecommendations(List<String> bookTitles, {
    RxList<Book>? targetList,
    bool clearBeforeAdd = true,
  }) async {
    // Create a local mutex/lock per target list to prevent concurrent modifications
    final targetKey = targetList?.hashCode ?? 'default';
    print('Starting search for books, target: $targetKey');

    // Create a temporary list to collect results
    List<Book> finalBookList = [];

    // Clear the target list if requested
    if (targetList != null && clearBeforeAdd) {
      print('Clearing target list (${targetList
          .length} items) before adding books');
      targetList.clear();
    } else if (targetList == null && clearBeforeAdd) {
      print('Clearing searchedBooks before adding books');
      searchedBooks.clear();
    }

    print('Searching for ${bookTitles.length} books');
    for (var title in bookTitles) {
      try {
        final book = await searchBookByAI(title);
        if (book != null) {
          finalBookList.add(book);
          print('Added book: ${book.title} to results');
        } else {
          print('Book not found: $title');
        }
      } catch (e) {
        print('Error searching for book "$title": $e');
      }
    }

    // Add all found books to the appropriate target list
    if (targetList != null) {
      print('Adding ${finalBookList.length} books to specific target list');
      targetList.addAll(finalBookList);
      print('Target list now has ${targetList.length} books');
      // Force refresh to ensure UI updates
      targetList.refresh();
    } else {
      print(
          'Adding ${finalBookList.length} books to default searchedBooks list');
      searchedBooks.addAll(finalBookList);
      print('SearchedBooks now has ${searchedBooks.length} books');
      // Force refresh to ensure UI updates
      searchedBooks.refresh();
    }
  }

  Future<void> getContentRecs(String bookName) async {
    isContentRecsLoading.value = true;
    try {
      final bookList = await _appwriteService.getContentRecommendations(
          bookName);
      print('Content recommendations for $bookName: $bookList');

      // Explicitly specify which list to use
      await searchBooksByAIRecommendations(
          bookList,
          targetList: contentRecBooks,
          // Use a specific list for content recommendations
          clearBeforeAdd: true
      );
    } catch (e) {
      print('Error getting content recommendations: $e');
    } finally {
      isContentRecsLoading.value = false;
    }
  }

  Future<void> getUserRecs() async {
    final userId = bookController.userId;
    if (userRecBooks != null && userRecBooks.isNotEmpty) {
      return;
    }

    // Don't return early if userId is null
    if (userId == null) {
      print('User ID is null, cannot fetch recommendations');
      return;
    }

    isUserRecsLoading.value = true;

    try {
      // First check if user exists in preferences collection
      final userPrefs = await _appwriteService.getUserPreferences(userId);

      if (userPrefs != null && userPrefs.data.isNotEmpty) {
        // New user with preferred categories
        print('Found preferred categories for user: $userId');
        final categories = List<String>.from(userPrefs.data['preferred_categories']);

        // Get books based on preferred categories
        List<String> allBookTitles = [];
        for (final category in categories) {
          final categoryBooks = await _fetchBooksByCategory(category);
          allBookTitles.addAll(categoryBooks);
        }

        // Limit to 10 books and shuffle for variety
        if (allBookTitles.isNotEmpty) {
          allBookTitles.shuffle();
          final limitedTitles = allBookTitles.take(10).toList();
          await searchBooksByAIRecommendations(
              limitedTitles, targetList: userRecBooks, clearBeforeAdd: true);
          print('Category-based recommendations added: ${userRecBooks.length}');
        } else {
          print('No category-based books found');
          userRecBooks.clear();
        }
      } else {
        // Existing user - use regular recommendations
        print('Fetching recommendations for existing user: $userId');
        final titles = await _appwriteService.fetchUserRecommendations(userId);

        if (titles.isNotEmpty) {
          await searchBooksByAIRecommendations(
              titles, targetList: userRecBooks, clearBeforeAdd: true);
          print('User rec books after fetch: ${userRecBooks.length}');
        } else {
          userRecBooks.clear();
          print('No titles found, cleared userRecBooks');
        }
      }
    } catch (e) {
      print('Error fetching user recommendations: $e');
      // Clear the list on error
      userRecBooks.clear();
    } finally {
      isUserRecsLoading.value = false;
    }
  }

// Helper method to fetch books by category
  Future<List<String>> _fetchBooksByCategory(String category) async {
    try {
      // Convert category to API-friendly format
      final apiCategory = category.toLowerCase().replaceAll(' ', '+');

      // Use Google Books API to fetch books by category
      final url = 'https://www.googleapis.com/books/v1/volumes?q=subject:$apiCategory&maxResults=4&orderBy=relevance';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List?;

        if (items == null || items.isEmpty) {
          return [];
        }

        return items.map<String>((item) {
          return item['volumeInfo']['title'] as String;
        }).toList();
      } else {
        print('Error fetching books from Google API: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception fetching books by category: $e');
      return [];
    }
  }

  Future<void> fetchTrendingBooks({
    String listName = 'hardcover-fiction',
    String date = 'current',
  }) async {
    print("finding trending books");
    print(trendingBooks);
    if (trendingBooks.isNotEmpty) {
      return;
    }
    final apiKey = '7r65ClbozadEyZeYdWotZvFBtdHTy5UC';
    final url = 'https://api.nytimes.com/svc/books/v3/lists/$date/$listName.json?api-key=$apiKey';

    try {
      print('trending function starting');
      isTrendingLoading.value = true;
      final response = await http.get(Uri.parse(url));
      print('API response code: ${response.statusCode}');
      print('API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final books = data['results']['books'] as List;
        print(books);

        // Extract book titles from the response
        final bookList = books.map<String>((book) => book['title'] as String)
            .toList();
        print("trending book list");
        print(bookList);
        await searchBooksByAIRecommendations(
            bookList, targetList: trendingBooks, clearBeforeAdd: true);
      } else {
        throw Exception('Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching trending books: $e');
    } finally {
      isTrendingLoading.value = false;
    }
  }

  // Helper to convert user-friendly category to API terms
  String _mapCategoryToApiTerm(String category) {
    final Map<String, String> categoryMapping = {
      'Fiction': 'fiction',
      'Mystery & Thriller': 'mystery+thriller',
      'Science Fiction & Fantasy': 'science+fiction',
      'Romance': 'romance',
      'Non-Fiction': 'non-fiction',
      'Biography & Memoir': 'biography',
      'Self-Help': 'self-help',
      'History': 'history',
      'Young Adult': 'young+adult',
      'Science & Technology': 'science',
    };

    return categoryMapping[category] ?? category.toLowerCase().replaceAll(' ', '+');
  }
}


