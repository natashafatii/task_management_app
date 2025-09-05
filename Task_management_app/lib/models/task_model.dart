class Task {
  final String id;
  String title;
  String description;
  final DateTime createdAt;
  bool isCompleted;
  String priority;
  DateTime? dueDate;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.isCompleted = false,
    this.priority = 'Medium',
    this.dueDate,
  });

  /// Convert Task to Map (for storage, e.g., shared preferences or database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  /// Create a Task object from Map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
      isCompleted: map['isCompleted'] ?? false,
      priority: map['priority'] ?? 'Medium',
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
    );
  }

  /// Copy a task with updated fields (useful for EditTaskScreen)
  Task copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    String? priority,
    DateTime? dueDate,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}