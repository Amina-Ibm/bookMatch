import 'package:animated_rating_stars/animated_rating_stars.dart';
import 'package:bookmatch/data/Books.dart';
import 'package:bookmatch/widgets/bookInfoRow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Controllers/BookListController.dart';
import '../models/book.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:colorful_iconify_flutter/icons/noto.dart';
import 'package:colorful_iconify_flutter/icons/flat_color_icons.dart';
import 'package:get/get.dart';
class bookDetailScreen extends StatelessWidget {
  bookDetailScreen({super.key, required this.book});
  final Book book;

  final controller = Get.put(BookListController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
        actions: [
          PopupMenuButton<readingStatus>(
            onSelected: (value) => controller.updateBookStatus(book, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: readingStatus.Reading,
                child: Text('Add to Currently Reading'),
              ),
              const PopupMenuItem(
                value: readingStatus.toRead,
                child: Text('Add to To Read'),
              ),
              const PopupMenuItem(
                value: readingStatus.Finished,
                child: Text('Add to Finished'),
              ),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10),
            Image.network(book.thumbnail),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Theme.of(context).primaryColor, // Directly using primary color
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
              ).merge(Theme.of(context).elevatedButtonTheme.style),
              onPressed: () => controller.launchOnKindle(book.title),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Iconify(FlatColorIcons.kindle, size: 24),
                  SizedBox(width: 8),
                  Text('Buy on Kindle'),
                ],
              ),
            ),
            SizedBox(height: 10,),
            Text("Description", style:Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).primaryColor)),
            Obx(() => Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text.rich(
                TextSpan(
                  text: controller.isExpanded.value
                      ? book.description
                      : book.description.length > 100
                      ? book.description.substring(0, 100) + "..."
                      : book.description,
                  style: TextStyle(color: Colors.black),
                  children: [
                    if (book.description.length > 100)
                      TextSpan(
                        text: controller.isExpanded.value ? " Read Less" : " Read More",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).primaryColor),
                        recognizer: TapGestureRecognizer()..onTap = controller.toggleDescription,
                      ),
                  ],
                ),
              ),
            )),
            SizedBox(height: 15),
            Text("Book Details", style:Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).primaryColor)),
            bookInfoRow(icon: Iconify(Noto.books), title: 'Category', info: book.category),
            bookInfoRow(icon: Iconify(FlatColorIcons.businessman), title: 'Publisher', info: book.publisher),
            bookInfoRow(icon: Iconify(FlatColorIcons.reading), title: 'Number of Pages', info: book.pageCount.toString()),
            bookInfoRow(icon: Iconify(FlatColorIcons.calendar), title: 'Published Date', info: book.publishedDate),
          ],
        ),
      ),
    );
  }
}
