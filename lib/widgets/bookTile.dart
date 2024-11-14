import 'package:book_next/models/book.dart';
import 'package:flutter/material.dart';

class bookTile extends StatelessWidget {
  bookTile({super.key, required this.book});
  final Book book;
  Widget build(BuildContext context){
    return ListTile(
      leading: Image.network(book.smallThumbnail),
      title: Text(book.author),
      trailing: Icon(Icons.arrow_forward_rounded),
    );
    }
  }
