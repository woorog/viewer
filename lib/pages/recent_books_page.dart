import 'package:flutter/material.dart';

import '../models/recent_book.dart';
import '../services/recent_book_service.dart';

class RecentBooksPage extends StatelessWidget {
  const RecentBooksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<RecentBook> books = RecentBookService.getBooks();

    return Scaffold(
      appBar: AppBar(
        title: const Text("최근 본 책"),
      ),
      body: books.isEmpty
          ? const Center(
        child: Text(
          "최근 본 책이 없습니다.",
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.separated(
        itemCount: books.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final book = books[index];

          return ListTile(
            leading: const Icon(Icons.menu_book),

            title: Text(
              book.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            subtitle: Text(book.episode),

            trailing: const Icon(Icons.chevron_right),

            onTap: () {
              // BrowserPage로 URL 반환
              Navigator.pop(context, book.url);
            },
          );
        },
      ),
    );
  }
}