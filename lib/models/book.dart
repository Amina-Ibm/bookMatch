import 'package:flutter/material.dart';

import '../Theme/appTheme.dart';

enum readingStatus {
  None,
  toRead,
  Reading,
  Finished
}
extension ReadingStatusExtension on readingStatus {
  Color get color {
    switch (this) {
      case readingStatus.toRead:
        return AppTheme.bookToRead;
      case readingStatus.Reading:
        return AppTheme.bookReading;
      case readingStatus.Finished:
        return AppTheme.bookRead;
      case readingStatus.None:
        return Colors.grey;
    }
  }
}

class Book{
  Book({required this.title,
    required this.author,
    required this.category,
    required this.publisher,
    required this.pageCount,
    required this.smallThumbnail,
    required this.thumbnail,
    required this.description,
    required this.publishedDate,
    this.status,
    this.id
  });

  final String title;
  final String author;
  final String publisher;
  final String category;
  final int pageCount;
  final String smallThumbnail;
  final String thumbnail;
  final String description;
  final String publishedDate;
  readingStatus? status;
  final String? id;


  factory Book.fromJsonWithGoogleApi(Map<String, dynamic> data) {
    var bookInfo = data['volumeInfo'] ?? {};
    return Book(
      title: bookInfo['title'] ?? 'Unknown Title',
      author: (bookInfo['authors'] != null && bookInfo['authors'].isNotEmpty)
          ? bookInfo['authors'][0]
          : 'Unknown Author',
      category: (bookInfo['categories'] != null && bookInfo['categories'].isNotEmpty)
          ? bookInfo['categories'][0]
          : 'Unknown Category',
      publisher: bookInfo['publisher'] ?? 'Unknown Publisher',
      pageCount: bookInfo['pageCount'] ?? 0,
      smallThumbnail: (bookInfo['imageLinks'] != null &&
          bookInfo['imageLinks']['smallThumbnail'] != null)
          ? bookInfo['imageLinks']['smallThumbnail']
          : 'https://static-00.iconduck.com/assets.00/no-image-icon-256x256-blc2175p.png',
        thumbnail: (bookInfo['imageLinks'] != null &&
            bookInfo['imageLinks']['thumbnail'] != null)
            ? bookInfo['imageLinks']['thumbnail']
            : 'https://static-00.iconduck.com/assets.00/no-image-icon-256x256-blc2175p.png',
        description: bookInfo['description'] ?? 'No description found.',
      publishedDate: bookInfo['publishedDate'] ?? 'Unknown published date',
      status: null

        
    );
  }
  factory Book.fromJsonWithAppwrite(Map<String, dynamic> data) {
    return Book(
      title: data['title'] ?? 'Unknown Title',
      author: data['author'] ?? 'Unknown Author',
      category: data['category'] ?? 'Unknown Category',
      publisher: data['publisher'] ?? 'Unknown Publisher',
      pageCount: data['pageCount'] ?? 0,
      smallThumbnail: data['smallThumbnail'] ??
          'https://static-00.iconduck.com/assets.00/no-image-icon-256x256-blc2175p.png',
      thumbnail: data['thumbnail'] ??
          'https://static-00.iconduck.com/assets.00/no-image-icon-256x256-blc2175p.png',
      description: data['description'] ?? 'No description found.',
      publishedDate: data['publishedDate'] ?? 'Unknown published date',
        status: readingStatus.values.firstWhere(
    (e) => e.toString().split('.').last == data['status'],

    ),
      id: data[r'$id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'publisher': publisher,
      'category': category,
      'pageCount': pageCount,
      'smallThumbnail': smallThumbnail,
      'thumbnail': thumbnail,
      'description': description,
      'publishedDate': publishedDate,
      'status': status != null ? status.toString().split('.').last : null, // Convert enum to string
    };
  }
}

List<String> categories = [
  'Fiction',
  'Mystery & Thriller',
  'Science Fiction & Fantasy',
  'Romance',
  'Non-Fiction',
  'Biography & Memoir'
  'Self-Help & Personal Development',
  'History',
  'Young Adult',
  'Science & Technology'
];