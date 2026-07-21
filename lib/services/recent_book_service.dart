import '../models/recent_book.dart';

class RecentBookService {
  static final List<RecentBook> _books = [];

  static Future<void> save(RecentBook book) async {
    _books.removeWhere((e) => e.title == book.title);

    _books.insert(0, book);

    if (_books.length > 30) {
      _books.removeLast();
    }
  }

  static List<RecentBook> getBooks() {
    return List.unmodifiable(_books);
  }

  static Future<void> clear() async {
    _books.clear();
  }
}