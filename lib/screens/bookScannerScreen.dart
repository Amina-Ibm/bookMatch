import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../Controllers/ApiController.dart';
import '../models/book.dart';
import 'bookDetailScreen.dart';

class BookScannerScreen extends StatefulWidget {
  @override
  _BookScannerScreenState createState() => _BookScannerScreenState();
}

class _BookScannerScreenState extends State<BookScannerScreen> with WidgetsBindingObserver {
  final APIController bookApiController = Get.find();
  late final MobileScannerController controller;
  StreamSubscription<Object?>? _subscription;
  String scannedISBN = '';
  bool hasNavigated = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
    WidgetsBinding.instance.addObserver(this);

    // Start listening to the barcode events
    _subscription = controller.barcodes.listen(_handleBarcode);

    // Start the scanner
    controller.start();
  }
  Future<void> searchBookByISBN(String isbn) async {
    final String apiKey = 'AIzaSyBN-5o54DzX9NryLyOpm_mAf8jZMpcYpHo';
    if (hasNavigated) return;
    final url = Uri.https('www.googleapis.com', '/books/v1/volumes', {
      'q': 'isbn:$isbn',
      'key': apiKey,
    });

    try {
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});
      final fetchedData = jsonDecode(response.body);

      if (fetchedData != null && fetchedData['items'] != null) {
        final books = fetchedData['items'].map<Book>((item) => Book.fromJsonWithGoogleApi(item)).toList();
        if (books.isNotEmpty) {
          hasNavigated = true;
          Get.to(() => bookDetailScreen(book: books[0]));
        }
      } else {
        print('No books found for the ISBN.');
      }
    } catch (e) {
      print('Error fetching book by ISBN: $e');
    }
  }
  void _handleBarcode(BarcodeCapture capture) {
    final Barcode? capturedCode = capture.barcodes.firstOrNull;
    final String code = capturedCode?.rawValue ?? '';
    if (code.length == 13 && RegExp(r'^\d{13}$').hasMatch(code)) {
      setState(() {
        scannedISBN = code;
      });
      searchBookByISBN(code);
      hasNavigated = true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid ISBN-13 detected')),
      );
    }
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.value.hasCameraPermission) return;
    switch (state) {
      case AppLifecycleState.resumed:
        _subscription = controller.barcodes.listen(_handleBarcode);
        controller.start();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        _subscription?.cancel();
        _subscription = null;
        controller.stop();
        break;
      default:
        break;
    }
  }
  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await _subscription?.cancel();
    await controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan ISBN-13')),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: controller,
              onDetect: _handleBarcode,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              scannedISBN.isEmpty
                  ? 'Scan a book barcode'
                  : 'Scanned ISBN-13: $scannedISBN',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}