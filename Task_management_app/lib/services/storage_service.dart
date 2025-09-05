import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static const String _tasksKey = 'tasks';

  Future<void> saveTasks(List<Map<String, dynamic>> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = tasks.map((task) => task).toList();
    await prefs.setString(_tasksKey, json.encode(tasksJson));
  }

  Future<List<Map<String, dynamic>>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString(_tasksKey);
    if (tasksJson != null) {
      final List<dynamic> tasksList = json.decode(tasksJson);
      return tasksList.cast<Map<String, dynamic>>();
    }
    return [];
  }
}