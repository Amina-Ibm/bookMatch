import 'package:bookmatch/models/book.dart';
import 'package:flutter/material.dart';

class bookTileSearch extends StatelessWidget {
  bookTileSearch({super.key, required this.book});
  final Book book;
  Widget build(BuildContext context){
    return ListTile(
      leading: Image.network(book.smallThumbnail),
      title: Text(book.title),
      trailing: Icon(Icons.arrow_forward_rounded),
    );
    }
  }
