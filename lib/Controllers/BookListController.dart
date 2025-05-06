import 'dart:ffi';

import 'package:animated_rating_stars/animated_rating_stars.dart';
import 'package:bookmatch/data/Books.dart';
import 'package:bookmatch/widgets/bookInfoRow.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/book.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:colorful_iconify_flutter/icons/noto.dart';
import 'package:colorful_iconify_flutter/icons/flat_color_icons.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:bookmatch/services/auth_service.dart';

import '../services/appwrite_service.dart';

class BookListController extends GetxController {
  final AuthService _authService = AuthService();
  final AppwriteService _appwriteService = AppwriteService();

  final RxBool isExpanded = false.obs;
  String? userId;
  @override
  void onInit() {
    super.onInit();
    getUserId();
  }
  Future<void> getUserId() async {
    try {
      // Check if we have a valid authenticated session first
      bool isLoggedIn = await _authService.isAuthenticated();

      if (isLoggedIn) {
        final user = await _authService.getCurrentUser();
        print(user);

        if (user != null) {
          userId = user.$id;
          update();
        } else {
          print('User is authenticated but user data is null');
        }
      } else {
        print('No authenticated user session found');
        // Handle the case where user is not logged in
        // This might be redirecting to login or setting a guest state
      }
    } catch (e) {
      print('Error getting user ID: $e');
    }
  }
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

  void updateBookStatus(Book book, readingStatus newStatus) async {
    if (book.status == null){
      AppwriteService().addBookToReadingList(book, userId!, newStatus );
    }
    if (book.status == newStatus) {
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text(""),
        description: Text("'${book.title}' is already in ${newStatus.name} collection"),
        alignment: Alignment.bottomCenter,
        autoCloseDuration: const Duration(seconds: 2),
        animationBuilder: (context, animation, alignment, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
      return;
    }

    try {
      if (newStatus == readingStatus.Finished) {
        showRatingDialog(book, newStatus);
      } else {
        await updateStatusinDB(book, newStatus);
        toastification.show(
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          title: Text(""),
          description: Text("'${book.title}' moved to ${newStatus.name} collection."),
          alignment: Alignment.bottomCenter,
          autoCloseDuration: const Duration(seconds: 2),
          animationBuilder: (context, animation, alignment, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      }
    } catch (e) {
      print("Error updating book status: $e");
    }
  }
  Future<void> deleteBook(Book book) async {
    if (userId == null) return;

    try {
      await AppwriteService().deleteBookFromReadingList(book.id!);
      toastification.show(
        type: ToastificationType.success,
        style: ToastificationStyle.flatColored,
        title: const Text(""),
        description: Text("'${book.title}' was removed from your list."),
        alignment: Alignment.bottomCenter,
        autoCloseDuration: const Duration(seconds: 2),
        animationBuilder: (context, animation, alignment, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
    } catch (e) {
      print("Error deleting book: $e");
    }
  }


  Future<void> updateStatusinDB(Book book, readingStatus newStatus) async {
    await AppwriteService().updateBookStatus(book.id!, newStatus);
    book.status = newStatus;
    update();
  }

  Future<Map<readingStatus, int>> fetchReadingStats(String userId) async {
    final statuses = [
      readingStatus.Reading,
      readingStatus.Finished,
      readingStatus.toRead
    ];

    Map<readingStatus, int> stats = {};

    // Fetch books for each status and count them
    for (readingStatus status in statuses) {
      try {

        final books = await _appwriteService.fetchBooksByStatus(userId, status);
        stats[status] = books.length;
      } catch (e) {
        // If there's an error fetching a particular status, set count to 0
        stats[status] = 0;
        print('Error fetching $status books: $e');
      }
    }

    return stats;
  }
// }

  void showRatingDialog(Book book, readingStatus newStatus) {
    double userRating = 3;

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
                onPressed: () async {
                  try {
                    await AppwriteService().addUserRatingToDb(userId!, book, userRating);
                    await updateStatusinDB(book, newStatus);
                  } catch (e) {
                    print("Error: $e");
                  } finally {
                    Get.back();
                    //Navigator.pop(BuildContext as BuildContext );// ensure the dialog always closes
                  }
                },
                child: Text("Submit"),
              ),
            ],
          ),
        ],
      ),
    );
  }

}