import 'dart:convert';
import 'package:bookmatch/Controllers/ApiController.dart';
import 'package:bookmatch/screens/bookDetailScreen.dart';
import 'package:bookmatch/widgets/emotionBasedRecs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class searchBookScreen extends StatefulWidget{
  searchBookScreen({super.key});
  @override
  State<searchBookScreen> createState() {
    return _searchBookScreenState();
  }
}

class _searchBookScreenState extends State<searchBookScreen>{
  final APIController bookApiController = Get.put(APIController());
  final bookNameController = TextEditingController();
  @override
  void initState() {
    super.initState();
    bookApiController.searchedBooks.clear();
  }
  void onSelectBook(BuildContext context, Book book){
    Navigator.push(context,
        MaterialPageRoute(builder: (ctx) =>
            bookDetailScreen(book: book) ));
  }
  Widget build(BuildContext context){
    final _formkey = GlobalKey<FormState>();
    return Scaffold(
        appBar: AppBar(
        title: Text('Search'),
          automaticallyImplyLeading: false,
    ),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Form
            Form(
              key: _formkey,
              child: TextFormField(
                controller: bookNameController,
                maxLength: 60,
                decoration: InputDecoration(
                  hintText: 'Search books, authors',
                  suffixStyle: Theme.of(context).textTheme.bodySmall,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  suffixIcon: IconButton(
                    onPressed: () => bookApiController.searchBook(bookNameController.text),
                    icon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                style: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 5),

            // Separator Text
            Center(
              child: Text(
                "Or",
                style: Theme.of(context).textTheme.bodyMedium),
              ),
            const SizedBox(height: 10),

            // Emotion-based Recommendations
            Center(
              child: Text(
                "Get Recommendations based on Emotions",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 10),
            EmotionChipsWidget(),
            const SizedBox(height: 20),

            // Book Results List
            Obx(() {
              if (bookApiController.isSearchLoading.value) {
                return const Center(
                  child: SizedBox(
                    height: 40,
                    width: 40,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                );
              }

              if (bookApiController.searchedBooks.isEmpty) {
                return Center(
                  child: Text(
                    "No books found",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: bookApiController.searchedBooks.length,
                itemBuilder: (ctx, index) {
                  final book = bookApiController.searchedBooks[index];

                  return ListTile(
                    leading: Image.network(book.smallThumbnail),
                    title: Text(
                      book.title,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
          ],
        ),
      ),
    ),
    );
  }
}