import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../services/reader_theme.dart';
import '../widgets/settings_sheet.dart';

class BrowserPage extends StatefulWidget {
  const BrowserPage({super.key});

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
            url: WebUri("https://www.google.com"),
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
          },
        ),
      ),

      // 왼쪽 아래 설정 버튼
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