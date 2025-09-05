import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'Task Manager';
  static const String appVersion = '1.0.0';

  // API Constants (if needed later)
  static const String baseUrl = 'https://api.example.com';
  static const int apiTimeout = 30000;

  // Storage Keys
  static const String tasksKey = 'tasks';
  static const String themeKey = 'theme';
  static const String languageKey = 'language';

  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';

  // Default Values
  static const String defaultPriority = 'Medium';
  static const int defaultTaskLimit = 100;
  static const int defaultDescriptionLength = 500;

  // Padding and Sizing
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultElevation = 4.0;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Task Priorities
  static const List<String> taskPriorities = ['High', 'Medium', 'Low'];

  // Priority Colors
  static const Color highPriorityColor = Colors.red;
  static const Color mediumPriorityColor = Colors.orange;
  static const Color lowPriorityColor = Colors.green;

  // Task Categories (if needed)
  static const List<String> taskCategories = [
    'Personal',
    'Work',
    'Shopping',
    'Health',
    'Education',
    'Other'
  ];
}