import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/recent_book.dart';

class RecentBookService {
  static const String _storageKey = "recent_books";

  static List<RecentBook> _books = [];

  /// 앱 시작 시 저장된 목록 불러오기
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final json = prefs.getString(_storageKey);

    if (json == null) {
      _books = [];
      return;
    }

    try {
      final List<dynamic> list = jsonDecode(json);

      _books = list
          .map(
            (e) => RecentBook.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList();
    } catch (e) {
      print("RecentBookService load Error: $e");
      _books = [];
    }
  }

  /// 내부 저장
  static Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();

    final json = jsonEncode(
      _books.map((e) => e.toJson()).toList(),
    );

    await prefs.setString(_storageKey, json);
  }

  /// 최근 본 책 저장
  static Future<void> save(RecentBook book) async {
    if (book.novelId.isNotEmpty) {
      _books.removeWhere(
            (e) =>
        e.novelId.isNotEmpty &&
            e.novelId == book.novelId,
      );
    } else {
      _books.removeWhere(
            (e) =>
        e.novelId.isEmpty &&
            e.title == book.title,
      );
    }

    _books.insert(0, book);

    if (_books.length > 30) {
      _books.removeLast();
    }

    await _saveToStorage();
  }

  /// 최근 본 책 목록
  static List<RecentBook> getBooks() {
    return List.unmodifiable(_books);
  }

  /// 최근 본 책 전체 삭제
  static Future<void> clear() async {
    _books.clear();

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_storageKey);
  }
}