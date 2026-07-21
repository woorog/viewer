import 'package:flutter/material.dart';
import 'pages/browser_page.dart';

void main() {
  runApp(const ViewerApp());
}

class ViewerApp extends StatelessWidget {
  const ViewerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BrowserPage(),
    );
  }
}