import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'SnapNote AI';
  static const String appTagline = 'Capture anything. Let AI organize it. Find it when you need it.';

  // Categories
  static const String catNote = 'note';
  static const String catEvent = 'event';
  static const String catReminder = 'reminder';
  static const String catTask = 'task';
  static const String catReadLater = 'read_later';
  static const String catIdea = 'idea';
  static const String catShopping = 'shopping';
  static const String catCode = 'code';
  static const String catPlace = 'place';

  static const List<String> allCategories = [
    catNote,
    catEvent,
    catReminder,
    catTask,
    catReadLater,
    catIdea,
    catShopping,
    catCode,
    catPlace,
  ];

  static String getCategoryLabel(String category) {
    switch (category.toLowerCase()) {
      case catNote:
        return 'Note';
      case catEvent:
        return 'Event';
      case catReminder:
        return 'Reminder';
      case catTask:
        return 'Task';
      case catReadLater:
        return 'Read Later';
      case catIdea:
        return 'Idea';
      case catShopping:
        return 'Shopping';
      case catCode:
        return 'Code';
      case catPlace:
        return 'Place';
      default:
        return category.toUpperCase();
    }
  }

  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case catNote:
        return Icons.article_rounded;
      case catEvent:
        return Icons.calendar_today_rounded;
      case catReminder:
        return Icons.alarm_rounded;
      case catTask:
        return Icons.check_circle_outline_rounded;
      case catReadLater:
        return Icons.menu_book_rounded;
      case catIdea:
        return Icons.lightbulb_rounded;
      case catShopping:
        return Icons.shopping_bag_rounded;
      case catCode:
        return Icons.code_rounded;
      case catPlace:
        return Icons.location_on_rounded;
      default:
        return Icons.note_rounded;
    }
  }

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case catNote:
        return const Color(0xFF6366F1); // Indigo
      case catEvent:
        return const Color(0xFFEC4899); // Pink
      case catReminder:
        return const Color(0xFFF59E0B); // Amber
      case catTask:
        return const Color(0xFF10B981); // Emerald
      case catReadLater:
        return const Color(0xFF3B82F6); // Blue
      case catIdea:
        return const Color(0xFF8B5CF6); // Purple
      case catShopping:
        return const Color(0xFF14B8A6); // Teal
      case catCode:
        return const Color(0xFF06B6D4); // Cyan
      case catPlace:
        return const Color(0xFFF43F5E); // Rose
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }
}
