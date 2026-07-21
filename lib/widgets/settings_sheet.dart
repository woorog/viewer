import 'package:flutter/material.dart';

class SettingsSheet extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;

  final VoidCallback onRecentBooks;

  final VoidCallback onChangeDefaultUrl;

  const SettingsSheet({
    super.key,
    required this.isDarkMode,
    required this.onDarkModeChanged,
    required this.onRecentBooks,
    required this.onChangeDefaultUrl,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "설정",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text("다크 모드"),
              trailing: Switch(
                value: isDarkMode,
                onChanged: onDarkModeChanged,
              ),
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text("최근 본 책"),
              trailing: const Icon(Icons.chevron_right),
              onTap: onRecentBooks,
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.language),
              title: const Text("기본 URL"),
              trailing: const Icon(Icons.chevron_right),
              onTap: onChangeDefaultUrl,
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}