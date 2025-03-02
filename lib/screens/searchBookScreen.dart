import 'dart:convert';
import 'package:bookmatch/Controllers/BooksApiController.dart';
import 'package:bookmatch/screens/bookDetailScreen.dart';
import 'package:bookmatch/widgets/emotionBasedRecs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
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
  final BooksAPIController bookApiController = Get.put(BooksAPIController());
  final bookNameController = TextEditingController();
  void onSelectBook(BuildContext context, Book book){
    Navigator.push(context,
        MaterialPageRoute(builder: (ctx) =>
            bookDetailScreen(book: book) ));
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
    suffix: IconButton(onPressed: (){bookApiController.searchBook(bookNameController.text);},
    icon: Icon(Icons.search))
    ),
    ),),
    Text("Or"),
    Text("Get Recommendations based on Emotions"),
    EmotionChipsWidget(),
    Expanded(child: Obx((){
      if(bookApiController.isLoading.value == true){
        return const Center(
            child: SizedBox(
              height: 40, // Adjust size
              width: 40,  // Adjust size
              child: CircularProgressIndicator(strokeWidth: 3),
            ));
      }
        if (bookApiController.finalBooks.isEmpty) {
        return const Center(child: Text("No books found"));
        }
        return ListView.separated(
    itemCount: bookApiController.finalBooks.length,
    itemBuilder: (ctx, index) {
      final book = bookApiController.finalBooks[index];
    return ListTile(
    leading: Image.network(book.smallThumbnail),
    title: Text(book.title),
    trailing: IconButton(
    onPressed: (){ onSelectBook(ctx, book); },
    icon: Icon(Icons.arrow_forward_rounded)),
    );
    }, separatorBuilder: (context, index) { return SizedBox(height: 10,); },);
    }
    ))
    ],
    )
    ),
    )
    )
    );
  }
}