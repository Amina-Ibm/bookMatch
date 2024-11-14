import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class searchBookScreen extends StatefulWidget{
  searchBookScreen({super.key});

  @override
  State<searchBookScreen> createState() {
    return _searchBookScreenState();
  }
}

class _searchBookScreenState extends State<searchBookScreen>{
  final String apiKey = 'AIzaSyBN-5o54DzX9NryLyOpm_mAf8jZMpcYpHo';
  final bookNameController = TextEditingController();
  final String maxTerms = '10';
  List<Book> finalBooks = [];

  Future<void> searchBook() async {
    List<Book> books = [];
    final searchTerm = bookNameController.text;
    final url = Uri.https('www.googleapis.com', '/books/v1/volumes', {'q': searchTerm, 'limit' : maxTerms, 'key': apiKey},);
    final Map<String, String> headers = {
      'Content-Type' : 'application/json'
    };
    final response = await http.get(url,
        headers: headers);
    print(response.body);
    final fetchedData = jsonDecode(response.body);

    if (fetchedData != null && fetchedData['items'] != null) {

      for (var item in fetchedData['items']) {
        books.add(Book.fromJson(item));
      }
      setState(() {
        finalBooks = books;
      });
    } else {
      print('No books found for the search term.');
    }
  }
  Widget build(BuildContext context){
    final _formkey = GlobalKey<FormState>();
    return MaterialApp(
        home: Scaffold(
        appBar: AppBar(
        title: Text('Search Book'),
    ),
    body: Padding(padding: EdgeInsets.all(20),
    child: Container(
    child: Column(
    mainAxisSize: MainAxisSize.min,

    children: [
    Form(
    key: _formkey,
    child: TextFormField(
    controller: bookNameController,
    maxLength: 60,
    decoration: InputDecoration(
    label: Text('Enter Book Name'),
    suffix: IconButton(onPressed: searchBook,
    icon: Icon(Icons.search))
    ),
    ),),

    if(finalBooks.isNotEmpty)
    Expanded(child: ListView.separated(
    itemCount: finalBooks.length,
    itemBuilder: (ctx, index) {
    return ListTile(
    leading: Image.network(finalBooks[index].smallThumbnail),
    title: Text(finalBooks[index].title),
    trailing: IconButton(
    onPressed: (){},
    icon: Icon(Icons.arrow_forward_rounded)),
    );
    }, separatorBuilder: (context, index) { return SizedBox(height: 10,); },
    ))
    ],
    )
    ),
    )
    )
    );
  }
}