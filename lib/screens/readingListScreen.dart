import 'package:bookmatch/Tabs/readingListWidget.dart';
import 'package:bookmatch/data/Books.dart';
import 'package:flutter/material.dart';
import '../models/book.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
class readingListScreen extends StatefulWidget {
  readingListScreen({super.key});

  @override
  State<readingListScreen> createState() {
    return _readingListScreenState();
  }
}

class _readingListScreenState extends State<readingListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  // Function to fetch books from Firestore based on reading status
  Future<List<Book>> fetchBooksFromFirestore(readingStatus status) async {

      try {
        String statusString = status.toString().split('.').last;
        String userId = "pbbRBAVug5ZHHM02xDO9";

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('readingLists')
          .doc('defaultReadingLists')
          .collection(statusString) // Status-based collection (read, toRead, etc.)
          .get();

      // Log the fetched data
      List<Book> books = snapshot.docs.map((doc) {
        var book = Book.fromJsonWithFirestore(doc.data() as Map<String, dynamic>);
        book.status = status; // Assign status based on collection
        return book;
      }).toList();
      // Convert Firestore documents to Book instances

      return books;
    } catch (e) {
      print("Error fetching books: $e");
      return [];
    }
  }


  // Widget to display the list of books
  Widget readingListView(readingStatus status) {
    return FutureBuilder<List<Book>>(
      future: fetchBooksFromFirestore(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No books found."));
        } else {
          return readingListWidget(
            filteredList: snapshot.data!,
            onStatusChange: (book, newStatus) => updateBookStatus(book, newStatus),
          );
        }
      },
    );
  }

  // Update book status locally and in Firestore
  void updateBookStatus(Book book, readingStatus newStatus) async {
    String userId = "pbbRBAVug5ZHHM02xDO9";

    try {
      // Get the current and new status collections
      String oldStatusString = book.status.toString().split('.').last;
      print(oldStatusString);
      String newStatusString = newStatus.toString().split('.').last;
      print(newStatusString);

      if (newStatusString == oldStatusString) {
        // If the book is already in the same collection, show a toast
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          title: Text(""),
          description: Text(
              "The book '${book.title}' is already in the $newStatusString collection"),
          alignment: Alignment.bottomCenter,
          autoCloseDuration: const Duration(seconds: 2),
          animationBuilder: (context, animation, alignment, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
        return; // Exit the function early
      }

      // Remove the book from the old collection
      QuerySnapshot oldStatusCollection = await _firestore
          .collection('users')
          .doc(userId)
          .collection('readingLists')
          .doc('defaultReadingLists')
          .collection(oldStatusString)
          .where('title', isEqualTo: book.title) // Assuming title is unique
          .get();

      for (var doc in oldStatusCollection.docs) {
        await doc.reference.delete(); // Delete the book document
        print("Book deleted from $oldStatusString collection.");
      }

      // Add the book to the new collection with the updated status
      QuerySnapshot existingBooks = await _firestore
          .collection('users')
          .doc(userId)
          .collection('readingLists')
          .doc('defaultReadingLists')
          .collection(newStatusString)
          .where('title', isEqualTo: book.title) // Assuming 'title' is unique
          .get();

      if (existingBooks.docs.isEmpty) {
        // Add the book only if it doesn't already exist
        book.status = newStatus;
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('readingLists')
            .doc('defaultReadingLists')
            .collection(newStatusString)
            .add(book.toMap());

        // Update local state after successful Firestore update
        setState(() {});

        print("Book moved to $newStatusString collection.");
        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          title: Text(""),
          description: Text("'${book.title}' moved to $newStatusString collection."),
          alignment: Alignment.bottomCenter,
          autoCloseDuration: const Duration(seconds: 2),
          animationBuilder: (context, animation, alignment, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
      } else {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          title: Text(""),
          description: Text(
              "'${book.title}' is already in $newStatusString collection"),
          alignment: Alignment.bottomCenter,
          autoCloseDuration: const Duration(seconds: 2),
          animationBuilder: (context, animation, alignment, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
      }
    } catch (e) {
      print("Error updating book status: $e");
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Library'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(child: Text("Current Reading", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black, fontSize: 12), softWrap: false,)),
            Tab(child: Text("Read", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black,  fontSize: 12))),
            Tab(child: Text("To Read", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black, fontSize: 12))),
          ],

        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: TabBarView(
          controller: _tabController,
          children: [
            readingListView(readingStatus.currentlyReading),
            readingListView(readingStatus.finished),
            readingListView(readingStatus.toRead),
          ],
        ),
      ),
    );
  }
}
