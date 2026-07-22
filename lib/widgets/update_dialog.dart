import 'package:flutter/material.dart';

class UpdateDialog extends StatelessWidget {
  final String currentVersion;
  final String latestVersion;
  final VoidCallback onUpdate;

  const UpdateDialog({
    super.key,
    required this.currentVersion,
    required this.latestVersion,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("업데이트"),
      content: Text(
        "새 버전이 있습니다.\n\n"
            "현재 : $currentVersion\n"
            "최신 : $latestVersion",
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("나중에"),
        ),
        FilledButton(
          onPressed: onUpdate,
          child: const Text("업데이트"),
        ),
      ],
    );
  }
}