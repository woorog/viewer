import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../models/recent_book.dart';

class NovelParser {
  static Future<RecentBook?> parse(
      InAppWebViewController controller,
      WebUri? url,
      ) async {
    try {
      final result = await controller.evaluateJavascript(
        source: """
document.querySelector('.page-title')?.innerText ?? "";
""",
      );

      String fullTitle = result?.toString() ?? "";

      fullTitle = fullTitle.replaceAll('"', '').trim();

      if (fullTitle.isEmpty) {
        return null;
      }



      // 마지막 "123화"를 화수로 인식
      final match = RegExp(r'(.+?)\s+(\d+화)$').firstMatch(fullTitle);

      if (match == null) {

        return null;
      }

      final title = match.group(1)!.trim();
      final episode = match.group(2)!.trim();



      return RecentBook(
        title: title,
        episode: episode,
        url: url?.toString() ?? "",
        lastRead: DateTime.now(),
      );
    } catch (e) {
      print("NovelParser Error : $e");
      return null;
    }
  }
}