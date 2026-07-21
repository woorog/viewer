import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../widgets/settings_sheet.dart';

class BrowserPage extends StatefulWidget {
  const BrowserPage({super.key});

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  InAppWebViewController? webViewController;

  bool isDarkMode = false;

  Future<void> _applyReaderTheme() async {
    if (webViewController == null) return;

    await webViewController!.evaluateJavascript(
      source: """
(function () {
  let style = document.getElementById("viewer-dark-theme");

  if (!style) {
    style = document.createElement("style");
    style.id = "viewer-dark-theme";
    document.head.appendChild(style);
  }

  style.innerHTML = `
    html, body {
      background:#111 !important;
      color:#EEE !important;
    }
  `;
})();
""",
    );
  }

  Future<void> _removeReaderTheme() async {
    if (webViewController == null) return;

    await webViewController!.evaluateJavascript(
      source: """
document.getElementById("viewer-dark-theme")?.remove();
""",
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

                setSheetState(() {});

                if (value) {
                  await _applyReaderTheme();
                } else {
                  await _removeReaderTheme();
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
      appBar: AppBar(
        title: const Text("Viewer"),
        centerTitle: true,
        backgroundColor: Colors.black.withOpacity(0.3),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: InAppWebView(
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          userAgent:
              "Mozilla/5.0 (Linux; Android 15; Pixel 9 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Mobile Safari/537.36",
        ),
        initialUrlRequest: URLRequest(url: WebUri("https://www.google.com")),
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
        onLoadStop: (controller, url) async {
          await controller.evaluateJavascript(
            source: """
document.getElementById('main-banner-view')
?.style.setProperty('display', 'none', 'important');
""",
          );

          if (isDarkMode) {
            await _applyReaderTheme();
          }
        },
      ),
    );
  }
}
