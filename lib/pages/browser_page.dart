import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../pages/recent_books_page.dart';

import '../services/novel_parser.dart';
import '../services/reader_theme.dart';
import '../services/recent_book_service.dart';
import '../services/settings_service.dart';

import '../widgets/settings_sheet.dart';


import '../services/update_service.dart';
import '../widgets/update_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';


class BrowserPage extends StatefulWidget {
  final String? initialUrl;

  const BrowserPage({super.key, this.initialUrl});

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  InAppWebViewController? webViewController;

  bool isDarkMode = false;

  String _startUrl = "https://www.google.com";

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // 최근 본 책 불러오기
    await RecentBookService.load();

    // 기본 URL
    _startUrl = widget.initialUrl ?? await SettingsService.getDefaultUrl();

    // 다크모드
    isDarkMode = await SettingsService.getDarkMode();

    setState(() {
      _initialized = true;
    });
    //업데이트 비활성화
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _checkUpdate();
    // });
  }

  Future<void> _changeDefaultUrl() async {
    final controller = TextEditingController(
      text: await SettingsService.getDefaultUrl(),
    );

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("기본 URL"),

          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "https://example.com"),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("취소"),
            ),

            FilledButton(
              onPressed: () async {
                final url = controller.text.trim();

                if (url.isEmpty) return;

                await SettingsService.saveDefaultUrl(url);

                setState(() {
                  _startUrl = url;
                });

                Navigator.pop(context);

                if (webViewController != null) {
                  await webViewController!.loadUrl(
                    urlRequest: URLRequest(url: WebUri(url)),
                  );
                }

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("기본 URL이 저장되었습니다.")),
                );
              },
              child: const Text("저장"),
            ),
          ],
        );
      },
    );
  }

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

                await SettingsService.saveDarkMode(value);

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
                  MaterialPageRoute(builder: (_) => const RecentBooksPage()),
                );

                if (selectedUrl != null && webViewController != null) {
                  await webViewController!.loadUrl(
                    urlRequest: URLRequest(url: WebUri(selectedUrl)),
                  );
                }
              },

              onChangeDefaultUrl: () {
                Navigator.pop(context);
                _changeDefaultUrl();
              },
            );
          },
        );
      },
    );
  }


  Future<void> _checkUpdate() async {
    final package = await PackageInfo.fromPlatform();

    print("현재 버전 : ${package.version}");

    final latest = await UpdateService.getLatestVersion();

    print("최신 버전 : $latest");

    if (!mounted || latest == null) return;

    if (latest != package.version) {
      print("업데이트 있음");

      showDialog(
        context: context,
        builder: (_) => UpdateDialog(
          currentVersion: package.version,
          latestVersion: latest,
          onUpdate: () async {
            Navigator.pop(context);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BrowserPage(
                  initialUrl:
                  "https://github.com/woorog/viewer/releases/latest",
                ),
              ),
            );
          },
        ),
      );
    } else {
      print("최신 버전");
    }
  }


  Future<void> _parseCurrentPage(
      InAppWebViewController controller,
      WebUri? url,
      ) async {
    print("===== 페이지 변경 감지 =====");
    print("URL: $url");

    final book = await NovelParser.parse(controller, url);

    if (book != null) {
      await RecentBookService.save(book);

      print("최근 기록 저장 완료");
      print("작품: ${book.title}");
      print("회차: ${book.episode}");
    }
  }



  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (webViewController != null && await webViewController!.canGoBack()) {
          await webViewController!.goBack();
        } else {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },

      child: Scaffold(
        body: SafeArea(
          child: InAppWebView(
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              userAgent:
                  "Mozilla/5.0 (Linux; Android 15; Pixel 9 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Mobile Safari/537.36",
            ),

            initialUrlRequest: URLRequest(url: WebUri(_startUrl)),

            onWebViewCreated: (controller) {
              webViewController = controller;
            },

            // SPA 방식으로 URL만 바뀌는 경우
            onUpdateVisitedHistory: (controller, url, androidIsReload) async {
              print("===== URL 변경 감지 =====");
              print("변경된 URL: $url");

              // 새 회차 DOM이 만들어질 때까지 기다림
              await controller.evaluateJavascript(
                source: r'''
(async () => {
  for (let i = 0; i < 20; i++) {

    const title = document.querySelector('h1.ne-h1');

    if (title && title.innerText.trim().length > 0) {
      return true;
    }

    await new Promise(resolve => setTimeout(resolve, 250));
  }

  return false;
})();
''',
              );

              if (!mounted) return;

              await _parseCurrentPage(controller, url);
            },

            onLoadStop: (controller, url) async {
              await controller.evaluateJavascript(
                source: r'''
(() => {
  // 메인 배너 제거
  document.getElementById('main-banner-view')
    ?.style.setProperty('display', 'none', 'important');

  // data-brs="header"인 section만 제거
  document
    .querySelector('section[data-brs="header"]')
    ?.style.setProperty('display', 'none', 'important');
})();
''',
              );

              // 다크모드
              if (isDarkMode) {
                await ReaderTheme.apply(controller);
              }

              // 작품 정보 저장
              final book = await NovelParser.parse(controller, url);

              if (book != null) {
                await RecentBookService.save(book);
              }
            },
          ),
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,

        floatingActionButton: FloatingActionButton.small(
          heroTag: "settings",
          backgroundColor: Colors.black.withOpacity(0.45),
          elevation: 0,
          onPressed: _showSettings,
          child: const Icon(Icons.settings),
        ),
      ),
    );
  }
  //zzzzzz zzzzz

  //zzzzzz zzzzz
  //zzzzzz zzzzz
}
