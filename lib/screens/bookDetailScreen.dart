import 'package:bookmatch/data/Books.dart';
import 'package:bookmatch/widgets/bookInfoRow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/book.dart';

class bookDetailScreen extends StatefulWidget{
  bookDetailScreen({super.key, required this.book});
  final Book book;

  @override
  State<bookDetailScreen> createState() {
    return _bookDetailScreenState();
  }
}
class _bookDetailScreenState extends State<bookDetailScreen>{
  void _launchOnKindle(String bookTitle) async {


    final searchedTitle = Uri.encodeComponent(bookTitle);
    final editedSearchedTitle = bookTitle.replaceAll(' ', '+');
    final rhValue = 'p_28:$editedSearchedTitle';
    final query = Uri.https(
      'www.amazon.com',
      '/s',
      {
        'i': 'digital-text',
        'rh': rhValue,
        's': 'relevanceexprank',
        'Adv-Srch-Books-Submit.x': '53',
        'Adv-Srch-Books-Submit.y': '9',
        'unfiltered': '1',
        'ref': 'sr_adv_b',
      },
    );
    print('starting search');
      await launchUrl(query, mode: LaunchMode.platformDefault);
      print('search ended');


  }
  void updateBookStatus(Book book, readingStatus newStatus) {
    setState(() {
      book.status = newStatus;
    });
    addBookToAppropriateList(book);
    readingListBooks.add(book);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.book.title} moved to ${newStatus.name}')),
    );
  }
  Future<void> addBookToAppropriateList(Book book) async {
    const String readingListId = "defaultReadingLists";
    const String userId = "pbbRBAVug5ZHHM02xDO9";
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    try {
      // Determine the correct subcollection
      String listName;
      switch (book.status) {
        case readingStatus.toRead:
          listName = "toRead";
          break;
        case readingStatus.currentlyReading:
          listName = "currentlyReading";
          break;
        case readingStatus.read:
          listName = "read";
          break;
        default:
          throw Exception("Invalid reading status.");
      }

      // Reference to the correct subcollection
      CollectionReference bookList = _firestore
          .collection('users')
          .doc(userId)
          .collection('readingLists')
          .doc(readingListId)
          .collection(listName);

      // Add the book
      await bookList.add(book.toMap());

      print("Book added to '$listName' list successfully!");
    } catch (e) {
      print("Error adding book to the appropriate list: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
        actions: [
        PopupMenuButton<readingStatus>(
        onSelected: (value) { updateBookStatus(widget.book, value);},
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: readingStatus.currentlyReading,
            child: Text('Add to Currently Reading'),
          ),
          const PopupMenuItem(
            value: readingStatus.toRead,
            child: Text('Add to To Read'),
          ),
          const PopupMenuItem(
            value: readingStatus.read,
            child: Text('Add to Read'),
          ),
        ],
      ),]),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(widget.book.thumbnail),
            Text(widget.book.title),
            TextButton(onPressed: (){_launchOnKindle(widget.book.title);}, child: Text('buy on Kindle')),

            Text("Description:"),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(widget.book.description),
            ),
            SizedBox(height: 15,),
            Text('Book Details'),
            bookInfoRow(icon: Icon(Icons.library_books), title: 'Category', info: widget.book.category,),
            bookInfoRow(icon: Icon(Icons.person), title: 'Publisher', info: widget.book.publisher,),
            bookInfoRow(icon: Icon(Icons.menu_book), title: 'Number of Pages', info: widget.book.pageCount.toString(),),
            bookInfoRow(icon: Icon(Icons.calendar_month), title: 'Published Date', info: widget.book.publishedDate,),

          ],
        ),
      )

    );

  }
}