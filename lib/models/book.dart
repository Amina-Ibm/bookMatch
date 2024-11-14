class Book{
  Book({required this.title,
    required this.author,
    required this.category,
    required this.publisher,
    required this.pageCount,
    required this.smallThumbnail
  });

  final String title;
  final String author;
  final String publisher;
  final String category;
  final int pageCount;
  final String smallThumbnail;


  factory Book.fromJson(Map<String, dynamic> data) {
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
          : 'https://static-00.iconduck.com/assets.00/no-image-icon-256x256-blc2175p.png'
    );
  }
}