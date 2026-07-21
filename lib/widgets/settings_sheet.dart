import 'package:flutter/material.dart';

class SettingsSheet extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;

  const SettingsSheet({
    super.key,
    required this.isDarkMode,
    required this.onDarkModeChanged,
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
          ],
        ),
      ),
    );
  }
}