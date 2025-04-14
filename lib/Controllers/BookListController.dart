import 'package:animated_rating_stars/animated_rating_stars.dart';
import 'package:bookmatch/data/Books.dart';
import 'package:bookmatch/widgets/bookInfoRow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/book.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:colorful_iconify_flutter/icons/noto.dart';
import 'package:colorful_iconify_flutter/icons/flat_color_icons.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:bookmatch/services/auth_service.dart';

class BookListController extends GetxController {
  final databases = Databases(AuthService().getClient());

  static const databaseId = '67f4f77f0025d8eb1e5f';
  static const readingListCollectionId = '67f8dc3c000f5d086dba';
  static const ratingsCollectionId = '67f4f79c001ef97d18dd';

  Future<String?> getUserId() async {
    models.User? user =  await AuthService().getCurrentUser();
    try{
      if(user != null){
        String userId = user.$id;
        return userId;
      }
    } catch (e) {
      print('Error getting user ID: $e');
      return '';
  }
}


  final RxBool isExpanded = false.obs;

  void toggleDescription() {
    isExpanded.value = !isExpanded.value;
  }

  Future<void> launchOnKindle(String bookTitle) async {
    final editedSearchedTitle = bookTitle.replaceAll(' ', '+');
    final rhValue = 'p_28:$editedSearchedTitle';
    final query = Uri.https(
      'www.amazon.com',
      '/s',
      {
        'i': 'digital-text',
        'rh': rhValue,
        's': 'relevanceexprank',
        'ref': 'sr_adv_b',
      },
    );
    await launchUrl(query, mode: LaunchMode.platformDefault);
  }

  void updateBookStatus(Book book, readingStatus newStatus) {
    if (newStatus == readingStatus.finished) {
      showRatingDialog(book, newStatus);
    } else {
      updateBookWithoutRating(book, newStatus);
    }
  }

  void updateBookWithoutRating(Book book, readingStatus newStatus) {
    book.status = newStatus;
    addBookToReadingList(book);
    Get.snackbar("Status Updated", "${book.title} moved to ${newStatus.name}");
  }

  void showRatingDialog(Book book, readingStatus newStatus) {
    double userRating = 3.0;

    Get.defaultDialog(
      title: "Rate '${book.title}'",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedRatingStars(
            initialRating: userRating,
            starSize: 18,
            minRating: 0,
            maxRating: 10,
            filledColor: Colors.amber,
            emptyColor: Colors.grey.shade300,
            onChanged: (rating) {
              userRating = rating;
            },
            displayRatingValue: true,
            customFilledIcon: Icons.star,
            customHalfFilledIcon: Icons.star_half,
            customEmptyIcon: Icons.star_border,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () => Get.back(), child: Text("Cancel")),
              ElevatedButton(
                onPressed: () {
                  addUserRatingToDb(book, userRating);
                  updateBookWithoutRating(book, newStatus);
                  Get.back();
                },
                child: Text("Submit"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> addUserRatingToDb(Book book, double rating) async{
    final ratingData = {
      ["userId"] : getUserId(),
      ["bookTitle"] : book.title,
      ["rating"] : rating
    };

    try{
      final result = await databases.createDocument(
        databaseId: databaseId,
        collectionId: ratingsCollectionId,
        documentId: ID.unique(), // 👈 Auto-generated
        data: ratingData,
      );
      print("rating added with ID: ${result.$id}");
  } on AppwriteException catch (e) {
  print('Error adding rating to database: ${e.message}');
  }
  }
  Future<void> addBookToReadingList(Book book) async {
    final bookData = book.toMap();
    bookData['userId'] = await getUserId();
    bookData['status'] = book.status!.name;
    try {
      final result = await databases.createDocument(
          databaseId: databaseId,
          collectionId: readingListCollectionId,
          documentId: ID.unique(), // 👈 Auto-generated
          data: bookData,
      );
      print("Book added with ID: ${result.$id}");
    } on AppwriteException catch (e) {
      print('Error adding book to reading list: ${e.message}');
    }
  }
}
