import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task? task;

  const TaskDetailScreen({super.key, this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late DateTime? _dueDate;
  late String _priority;
  bool _isEditing = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _isEditing = true;
      _title = widget.task!.title;
      _description = widget.task!.description;
      _dueDate = widget.task!.dueDate;
      _priority = widget.task!.priority;

      _titleController.text = _title;
      _descriptionController.text = _description;
      if (_dueDate != null) {
        _dueDateController.text = DateFormat.yMMMd().format(_dueDate!);
      }
    } else {
      _title = '';
      _description = '';
      _dueDate = null;
      _priority = 'Low';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1);
    final lastDate = DateTime(now.year + 5);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textLight,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _dueDate = pickedDate;
        _dueDateController.text = DateFormat.yMMMd().format(pickedDate);
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      if (_isEditing) {
        final updatedTask = widget.task!.copyWith(
          title: _title,
          description: _description,
          dueDate: _dueDate,
          priority: _priority,
        );
        taskProvider.updateTask(updatedTask);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task updated successfully!')),
        );
      } else {
        final newTask = Task(
          id: DateTime.now().toString(),
          title: _title,
          description: _description,
          dueDate: _dueDate,
          priority: _priority,
          isCompleted: false,
          createdAt: DateTime.now(),
        );
        taskProvider.addTask(newTask);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task added successfully!')),
        );
      }
      Navigator.pop(context);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Deletion", style: TextStyle(color: AppColors.textPrimary)),
          content: const Text("Are you sure you want to delete this task?", style: TextStyle(color: AppColors.textSecondary)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel", style: TextStyle(color: AppColors.primary)),
            ),
            ElevatedButton(
              onPressed: () {
                final taskProvider = Provider.of<TaskProvider>(context, listen: false);
                taskProvider.deleteTask(widget.task!.id);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Task deleted!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.textLight,
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Task' : 'Add Task',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: AppColors.textLight,
          ),
        ),
        centerTitle: false,
        backgroundColor: AppColors.primary,
        elevation: 0,
        toolbarHeight: 80,
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete, color: AppColors.error),
              tooltip: 'Delete Task',
            ),
          IconButton(
            onPressed: _saveTask,
            icon: const Icon(Icons.check, color: AppColors.textLight),
            tooltip: 'Save Task',
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormTitle('Title'),
              _buildTextFormField(
                controller: _titleController,
                hint: 'Task Title',
                validator: (value) => value!.trim().isEmpty ? 'Title cannot be empty' : null,
                onSaved: (value) => _title = value ?? '',
              ),
              const SizedBox(height: 20),

              _buildFormTitle('Description'),
              _buildTextFormField(
                controller: _descriptionController,
                hint: 'Task Description',
                maxLines: 5,
                onSaved: (value) => _description = value ?? '',
              ),
              const SizedBox(height: 20),

              _buildFormTitle('Due Date'),
              _buildTextFormField(
                controller: _dueDateController,
                hint: 'Select Due Date',
                readOnly: true,
                onTap: _presentDatePicker,
                suffixIcon: Icons.calendar_today,
              ),
              const SizedBox(height: 20),

              _buildFormTitle('Priority'),
              _buildPriorityDropdown(),
              const SizedBox(height: 20),

              if (_isEditing) ...[
                _buildFormTitle('Completion Status'),
                CheckboxListTile(
                  title: const Text('Mark as Completed'),
                  value: widget.task!.isCompleted,
                  onChanged: (bool? value) {
                    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
                    final updatedTask = widget.task!.copyWith(isCompleted: value!);
                    taskProvider.updateTask(updatedTask);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Task status updated!')),
                    );
                  },
                  activeColor: AppColors.primary,
                  checkColor: AppColors.textLight,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
    bool readOnly = false,
    void Function()? onTap,
    IconData? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      onSaved: onSaved,
      readOnly: readOnly,
      onTap: onTap,
      decoration: _inputDecoration(hint, suffixIcon: suffixIcon),
    );
  }

  Widget _buildPriorityDropdown() {
    return DropdownButtonFormField<String>(
       initialValue: _priority,
      decoration: _inputDecoration('Priority'),
      items: ['Low', 'Medium', 'High'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Row(
            children: [
              Icon(
                Icons.circle,
                color: _getPriorityColor(value),
                size: 12,
              ),
              const SizedBox(width: 8),
              Text(value, style: const TextStyle(color: AppColors.textPrimary)),
            ],
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _priority = newValue!;
        });
      },
      onSaved: (value) => _priority = value!,
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return AppColors.error;
      case 'Medium':
        return AppColors.warning;
      case 'Low':
      default:
        return AppColors.primary;
    }
  }

  InputDecoration _inputDecoration(String hint, {IconData? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      suffixIcon: suffixIcon != null
          ? Icon(suffixIcon, color: AppColors.textSecondary)
          : null,
    );
  }
}
