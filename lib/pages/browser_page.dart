import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class BrowserPage extends StatefulWidget {
  const BrowserPage({super.key});

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  InAppWebViewController? webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Viewer"),
        centerTitle: true,
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri("https://www.google.com"),
        ),
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
      ),
    );
  }
}