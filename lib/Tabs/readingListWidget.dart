import 'package:bookmatch/data/Books.dart';
import 'package:bookmatch/widgets/bookTileReadingList.dart';
import 'package:bookmatch/widgets/bookTileSearch.dart';
import 'package:flutter/material.dart';
import '../Controllers/BookListController.dart';
import '../models/book.dart';
import 'package:get/get.dart';


class readingListWidget extends StatefulWidget{
  readingListWidget({super.key, required this.filteredList, required this.onStatusChange, required this.onBookDeleted});
  final List<Book> filteredList;
  Function(Book, readingStatus) onStatusChange;
  final Function(Book)? onBookDeleted;
  @override
  State<readingListWidget> createState() {
    return _readingListWidgetState();
  }
}
class _readingListWidgetState extends State<readingListWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.filteredList.isEmpty) {
      return const Center(
        child: Text('Start organizing books by adding them to lists.'),
      );
    } else {
      return ListView.separated(
        itemBuilder: (ctx, index) {
          final book = widget.filteredList[index];
          return Dismissible(
            key: Key('${book.title}-${book.status}'),
            background: Container(
              color: Colors.redAccent,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            secondaryBackground: Container(
              color: Colors.redAccent,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.horizontal,
            onDismissed: (_) async {
              final controller = Get.find<BookListController>();
              await controller.deleteBook(book);
              if (widget.onBookDeleted != null) {
                widget.onBookDeleted!(book);
              }
            },

            child: bookTileReadingList(
              book: book,
              onStatusChange: widget.onStatusChange,
            ),
          );
        },
        separatorBuilder: (ctx, index) => const SizedBox(height: 10),
        itemCount: widget.filteredList.length,
      );
    }
  }
}
