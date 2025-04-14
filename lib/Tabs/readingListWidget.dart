import 'package:bookmatch/data/Books.dart';
import 'package:bookmatch/widgets/bookTileReadingList.dart';
import 'package:bookmatch/widgets/bookTileSearch.dart';
import 'package:flutter/material.dart';
import '../models/book.dart';


class readingListWidget extends StatefulWidget{
  readingListWidget({super.key, required this.filteredList, required this.onStatusChange});
  final List<Book> filteredList;
  Function(Book, readingStatus) onStatusChange;
  @override
  State<readingListWidget> createState() {
    return _readingListWidgetState();
  }
}
class _readingListWidgetState extends State<readingListWidget>{
  Widget build(BuildContext context) {

    if (widget.filteredList.isEmpty) {
      return Center(
        child: Text('Start organizing books by adding them to lists.'),
      );
    } else {
      return ListView.separated(
        itemBuilder: (ctx, index) =>
            bookTileReadingList(book: widget.filteredList[index], onStatusChange: widget.onStatusChange),
        separatorBuilder: (ctx, index) => SizedBox(height: 10),
        itemCount: widget.filteredList.length,
      );
    }
  }

}