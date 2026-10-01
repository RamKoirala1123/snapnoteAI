import 'package:flutter/material.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'dart:io';

class QuickEntryApp extends StatelessWidget {
  final String windowId;
  final String mainId;
  final String type;

  const QuickEntryApp({
    super.key,
    required this.windowId,
    required this.mainId,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF1E1E1E),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: InputDecoration(
                hintText: type == 'note' ? 'Write a quick note...' : 'Add a quick todo...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: InputBorder.none,
                icon: Icon(
                  type == 'note' ? Icons.notes : Icons.check_circle_outline,
                  color: Colors.blueAccent,
                ),
              ),
              onSubmitted: (text) async {
                if (text.isNotEmpty) {
                  await WindowController.fromWindowId(mainId).invokeMethod(
                    'save_quick_entry',
                    {'text': text, 'type': type},
                  );
                }
                exit(0); // Close the sub-window process entirely to clean up
              },
            ),
          ),
        ),
      ),
    );
  }
}
