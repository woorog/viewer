import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/recent_book.dart';

class RecentBookService {
  static const _storageKey = "recent_books";

  static List<RecentBook> _books = [];

  /// 앱 시작 시 저장된 목록 불러오기
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final json = prefs.getString(_storageKey);

    if (json == null) {
      _books = [];
      return;
    }

    final List list = jsonDecode(json);

    _books = list
        .map((e) => RecentBook.fromJson(e))
        .toList();
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
    // 같은 작품 제거
    _books.removeWhere((e) => e.title == book.title);

    // 맨 앞에 추가
    _books.insert(0, book);

    // 최대 30권
    if (_books.length > 30) {
      _books.removeLast();
    }

    await _saveToStorage();
  }

  /// 목록 가져오기
  static List<RecentBook> getBooks() {
    return List.unmodifiable(_books);
  }

  /// 삭제
  static Future<void> clear() async {
    _books.clear();

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_storageKey);
  }
}