import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();
  List<Task> get tasks => _taskService.tasks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await _taskService.loadTasks();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await _taskService.addTask(task);
    notifyListeners();
  }

  Future<void> updateTask(Task updatedTask) async {
    // Update in service
    await _taskService.updateTask(updatedTask);

    // Find the task locally and update
    final index = _taskService.tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _taskService.tasks[index] = updatedTask;
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    await _taskService.deleteTask(taskId);
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    await _taskService.toggleTaskCompletion(taskId);

    final index = _taskService.tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _taskService.tasks[index].isCompleted =
      !_taskService.tasks[index].isCompleted;
      notifyListeners();
    }
  }
}
