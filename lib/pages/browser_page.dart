import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../services/reader_theme.dart';
import '../widgets/settings_sheet.dart';
import 'recent_books_page.dart';


import '../services/novel_parser.dart';
import '../services/recent_book_service.dart';



class BrowserPage extends StatefulWidget {
  final String? initialUrl;

  const BrowserPage({
    super.key,
    this.initialUrl,
  });

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  InAppWebViewController? webViewController;

  bool isDarkMode = false;

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SettingsSheet(
              isDarkMode: isDarkMode,

              onDarkModeChanged: (value) async {
                setState(() {
                  isDarkMode = value;
                });

                setSheetState(() {});

                if (webViewController == null) return;

                if (value) {
                  await ReaderTheme.apply(webViewController!);
                } else {
                  await ReaderTheme.remove(webViewController!);
                }
              },

              onRecentBooks: () async {
                Navigator.pop(context);

                final String? selectedUrl = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RecentBooksPage(),
                  ),
                );

                if (selectedUrl != null && webViewController != null) {
                  await webViewController!.loadUrl(
                    urlRequest: URLRequest(
                      url: WebUri(selectedUrl),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: InAppWebView(
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            userAgent:
            "Mozilla/5.0 (Linux; Android 15; Pixel 9 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Mobile Safari/537.36",
          ),
          initialUrlRequest: URLRequest(
            url: WebUri(
              widget.initialUrl ?? "https://www.google.com",
            ),
          ),
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          onLoadStop: (controller, url) async {
            // 상단 배너 제거
            await controller.evaluateJavascript(
              source: """
document.getElementById('main-banner-view')
    ?.style.setProperty('display', 'none', 'important');
""",
            );

            // 다크모드 적용
            if (isDarkMode && webViewController != null) {
              await ReaderTheme.apply(webViewController!);
            }

            // 현재 작품 정보 읽기
            final book = await NovelParser.parse(controller, url);

            if (book != null) {
              print("===== 저장 시작 =====");
              print("제목 : ${book.title}");
              print("화수 : ${book.episode}");

              await RecentBookService.save(book);

              print("저장 완료");
              print("현재 저장 개수 : ${RecentBookService.getBooks().length}");

              // 저장된 목록 확인
              for (final b in RecentBookService.getBooks()) {
                print("${b.title} / ${b.episode}");
              }

              print("====================");
            } else {
              print("❌ NovelParser가 null을 반환했습니다.");
            }
          },
        ),
      ),

      floatingActionButtonLocation:
      FloatingActionButtonLocation.startFloat,

      floatingActionButton: FloatingActionButton.small(
        heroTag: "settings",
        backgroundColor: Colors.black.withOpacity(0.45),
        elevation: 0,
        onPressed: _showSettings,
        child: const Icon(Icons.settings),
      ),
    );
  }
}