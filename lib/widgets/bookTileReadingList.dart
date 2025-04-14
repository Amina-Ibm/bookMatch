import 'package:bookmatch/models/book.dart';
import 'package:flutter/material.dart';

import '../screens/bookDetailScreen.dart';

class bookTileReadingList extends StatefulWidget {
  bookTileReadingList({super.key, required this.book, required this.onStatusChange});
  final Book book;
   Function(Book, readingStatus) onStatusChange;

  @override
  State<bookTileReadingList> createState() => _bookTileReadingListState();
}

class _bookTileReadingListState extends State<bookTileReadingList> {
  Widget build(BuildContext context){
    return ListTile(
      leading: Image.network(widget.book.smallThumbnail),
      title: Text(widget.book.title,
      style: Theme.of(context).textTheme.bodyMedium,),
      trailing: PopupMenuButton<readingStatus>(
        onSelected: (value) {
          widget.onStatusChange(widget.book, value);


        },
      itemBuilder: (BuildContext context) => [
      const PopupMenuItem(
      value: readingStatus.toRead,
      child: Text("Move to To Read"),
    ),
    const PopupMenuItem(
    value: readingStatus.currentlyReading,
    child: Text("Move to Currently Reading"),
    ),
    const PopupMenuItem(
    value: readingStatus.finished,
    child: Text("Move to Finished"),
    ),
    ]
    ),
      onTap: () {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => bookDetailScreen(book: widget.book),
          ),
        );
      },
    );
  }
}
