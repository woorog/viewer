import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../models/recent_book.dart';

class NovelParser {
  static Future<RecentBook?> parse(
      InAppWebViewController controller,
      WebUri? url,
      ) async {
    try {
      final currentUrl = url?.toString() ?? "";

      print("===== NovelParser =====");
      print("현재 URL : $currentUrl");

      // =====================================================
      // 1. 기존 사이트
      // =====================================================

      final oldResult = await controller.evaluateJavascript(
        source: r'''
(() => {
  const element = document.querySelector('.page-title');

  if (!element) {
    return JSON.stringify({
      "site": "old",
      "title": "",
      "episode": ""
    });
  }

  const fullTitle = element.innerText.trim();

  const match = fullTitle.match(/^(.+?)\s+(\d+화)$/);

  if (!match) {
    return JSON.stringify({
      "site": "old",
      "title": "",
      "episode": ""
    });
  }

  return JSON.stringify({
    "site": "old",
    "title": match[1].trim(),
    "episode": match[2].trim()
  });
})();
''',
      );

      if (oldResult != null) {
        final oldData = jsonDecode(oldResult.toString());

        final oldTitle =
            oldData["title"]?.toString().trim() ?? "";

        final oldEpisode =
            oldData["episode"]?.toString().trim() ?? "";

        if (oldTitle.isNotEmpty && oldEpisode.isNotEmpty) {
          print("기존 사이트 감지");
          print("제목 : $oldTitle");
          print("회차 : $oldEpisode");

          return RecentBook(
            title: oldTitle,
            episode: oldEpisode,
            url: currentUrl,
            site: "old",
            lastRead: DateTime.now(),
          );
        }
      }

      // =====================================================
      // 2. 새 사이트
      //
      // /novel/63222/8498349
      // =====================================================

      final uri = Uri.tryParse(currentUrl);

      if (uri == null) {
        print("URL 파싱 실패");
        return null;
      }

      final pathSegments = uri.pathSegments;

      print("pathSegments : $pathSegments");

      // /novel/{작품ID}/{회차ID}
      if (pathSegments.length >= 3 &&
          pathSegments[0] == "novel") {
        final novelId = pathSegments[1];
        final episodeId = pathSegments[2];

        if (novelId.isNotEmpty && episodeId.isNotEmpty) {
          print("새 사이트 감지");
          print("작품 ID : $novelId");
          print("회차 ID : $episodeId");

          // 제목은 일단 DOM에서 가져오되,
          // 제목을 못 가져와도 URL 정보만으로 저장할 수 있게 함
          final titleResult =
          await controller.evaluateJavascript(
            source: r'''
(() => {
  const element = document.querySelector('.ne-h1');

  if (!element) {
    return "";
  }

  return element.innerText.trim();
})();
''',
          );

          String fullTitle =
              titleResult?.toString() ?? "";

          fullTitle = fullTitle
              .replaceAll('"', '')
              .trim();

          String title = "";
          String episode = "";

          // "장생종 연단종사 421화"
          final match =
          RegExp(r'^(.+?)\s+(\d+화)$')
              .firstMatch(fullTitle);

          if (match != null) {
            title = match.group(1)?.trim() ?? "";
            episode = match.group(2)?.trim() ?? "";
          }

          // 제목/회차 DOM 파싱 실패 시에도
          // URL의 ID를 이용해서 저장
          if (title.isEmpty) {
            title = "작품 $novelId";
          }

          if (episode.isEmpty) {
            episode = "회차 $episodeId";
          }

          print("제목 : $title");
          print("회차 : $episode");

          return RecentBook(
            title: title,
            episode: episode,
            url: currentUrl,
            novelId: novelId,
            episodeId: episodeId,
            thumbnail: "",
            site: "new",
            lastRead: DateTime.now(),
          );
        }
      }

      // =====================================================
      // 3. 인식 실패
      // =====================================================

      print("NovelParser: 작품 페이지 아님");

      return null;
    } catch (e, stack) {
      print("NovelParser Error : $e");
      print(stack);

      return null;
    }
  }
}