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
    bookApiController.searchedBooks.clear(); // Clear recommendations when entering the screen
  }
  void onSelectBook(BuildContext context, Book book){
    Navigator.push(context,
        MaterialPageRoute(builder: (ctx) =>
            bookDetailScreen(book: book) ));
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
                  onPressed: () => bookApiController.getContentRecs(enteredBookName.text),
                  icon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary), // Themed color
                ),
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 20), // Spacing

            Expanded(
              child: Obx(() {
                if (bookApiController.isContentRecsLoading.value) {
                  return const Center(
                    child: SizedBox(
                      height: 40, // Adjust size
                      width: 40,  // Adjust size
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                  );
                }
                if (bookApiController.contentRecBooks.isEmpty) {
                  return Center(
                    child: Text(
                      "No books found",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black),
                      ), // Themed text
                    );
                }

                return ListView.separated(
                  itemCount: bookApiController.contentRecBooks.length,
                  itemBuilder: (ctx, index) {
                    final book = bookApiController.contentRecBooks[index];
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