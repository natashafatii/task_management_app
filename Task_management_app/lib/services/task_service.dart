import '../models/task_model.dart';
import 'storage_service.dart';

class TaskService {
  final StorageService _storageService = StorageService();
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  Future<void> loadTasks() async {
    final tasksData = await _storageService.loadTasks();
    _tasks = tasksData.map((data) => Task.fromMap(data)).toList();
  }

  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await _saveTasks();
  }

  Future<void> updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      await _saveTasks();
    }
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
    await _saveTasks();
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      await _saveTasks();
    }
  }

  Future<void> _saveTasks() async {
    final tasksData = _tasks.map((task) => task.toMap()).toList();
    await _storageService.saveTasks(tasksData);
  }
}