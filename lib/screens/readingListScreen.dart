import 'package:bookmatch/Tabs/readingListWidget.dart';
import 'package:bookmatch/data/Books.dart';
import 'package:flutter/material.dart';
import '../models/book.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import 'package:bookmatch/Controllers/BookListController.dart';

import '../services/appwrite_service.dart';
class readingListScreen extends StatefulWidget {
  readingListScreen({super.key});

  @override
  State<readingListScreen> createState() {
    return _readingListScreenState();
  }
}

class _readingListScreenState extends State<readingListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  //final BookListController databaseController = Get.put(BookListController());
  final BookListController databaseController = Get.find();
  String? userId;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    userId = databaseController.userId;

  }
  // Widget to display the list of books
  Widget readingListView(readingStatus status) {
    return FutureBuilder<List<Book>>(
      future: AppwriteService().fetchBooksByStatus(userId!, status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No books found."));
        } else {
          return readingListWidget(
            filteredList: snapshot.data!,
            onStatusChange: (book, newStatus) {
              databaseController.updateBookStatus(book, newStatus);
              setState(() {});
            },
            onBookDeleted: (book) {
              setState(() {});
            }
          );


        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Library'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(child: Text("Current Reading", style: Theme
                .of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.black, fontSize: 12),
              softWrap: false,)),
            Tab(child: Text("Finished", style: Theme
                .of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.black, fontSize: 12))),
            Tab(child: Text("To Read", style: Theme
                .of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.black, fontSize: 12))),
          ],

        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: TabBarView(
          controller: _tabController,

          children: [

            readingListView(readingStatus.Reading),
            readingListView(readingStatus.Finished),
            readingListView(readingStatus.toRead),
          ],
        ),
      ),
    );
  }
}




