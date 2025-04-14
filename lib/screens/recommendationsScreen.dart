import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../Controllers/ApiController.dart';
import '../models/book.dart';
import 'bookDetailScreen.dart';
class RecommendationsScreen extends StatefulWidget {
  @override
  _RecommendationsScreenState createState() => _RecommendationsScreenState();
}
class _RecommendationsScreenState extends State<RecommendationsScreen> {
  final APIController bookApiController = Get.find();
  TextEditingController enteredBookName = TextEditingController();
  List<String> recommendedBooks = [];
  @override
  void initState() {
    super.initState();
    bookApiController.finalBooks.clear(); // Clear recommendations when entering the screen
  }
  void onSelectBook(BuildContext context, Book book){
    Navigator.push(context,
        MaterialPageRoute(builder: (ctx) =>
            bookDetailScreen(book: book) ));
  }
  Future<List<String>> fetchRecommendations(String bookName) async {
    final String apiUrl = "https://web-production-3a68d.up.railway.app/recommend?book=$bookName";
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      List<String> recommendations = List<String>.from(jsonResponse["recommended_books"]);
      return recommendations;
    } else {
      throw Exception("Failed to fetch recommendations");
    }
  }
  Future<void> getContentRecs(String bookName) async {
    bookApiController.isLoading.value = true;
    final bookList = await fetchRecommendations(bookName);
    print(bookList);
    bookApiController.searchBooksByAIRecommendations(bookList);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Book Recommendations")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Content-Based Recommendations",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
              // Title styling
            ),
            const SizedBox(height: 16), // Spacing

            TextField(
              controller: enteredBookName,
              decoration: InputDecoration(
                label: Text(
                  'Enter Book Name',
                  style: Theme.of(context).textTheme.bodyMedium, // Label styling
                ),
                suffixIcon: IconButton(
                  onPressed: () => getContentRecs(enteredBookName.text),
                  icon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary), // Themed color
                ),
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 20), // Spacing

            Expanded(
              child: Obx(() {
                if (bookApiController.isLoading.value) {
                  return const Center(
                    child: SizedBox(
                      height: 40, // Adjust size
                      width: 40,  // Adjust size
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                  );
                }
                if (bookApiController.finalBooks.isEmpty) {
                  return Center(
                    child: Text(
                      "No books found",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black),
                      ), // Themed text
                    );
                }

                return ListView.separated(
                  itemCount: bookApiController.finalBooks.length,
                  itemBuilder: (ctx, index) {
                    final book = bookApiController.finalBooks[index];
                    return ListTile(
                      leading: Image.network(book.smallThumbnail),
                      title: Text(
                        book.title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black), // Themed text
                      ),
                      trailing: IconButton(
                        onPressed: () => onSelectBook(ctx, book),
                        icon: Icon(Icons.arrow_forward_rounded, color: Theme.of(context).colorScheme.primary),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                );
              }),
            ),
          ],
        ),
      ),

    );
  }
}