import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;
  final Function(Task) onUpdate;
  final Function(String) onDelete; // New callback for deleting a task

  const EditTaskScreen({
    super.key,
    required this.task,
    required this.onUpdate,
    required this.onDelete, // New required parameter
  });

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _selectedDate;
  late String _priority;
  late bool _isCompleted;

  final List<String> _priorityOptions = ['High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _selectedDate = widget.task.dueDate;
    _priority = widget.task.priority;
    _isCompleted = widget.task.isCompleted;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime initialDate = _selectedDate ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.primaryLight,
              onSurface: Colors.black, // Changed from AppColors.text
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Task title cannot be empty"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final updatedTask = widget.task.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _selectedDate,
      priority: _priority,
      isCompleted: _isCompleted,
    );

    widget.onUpdate(updatedTask);

    // No need for a SnackBar here, as the parent widget can handle confirmation
    // based on the update. This prevents duplicate feedback.

    Navigator.pop(context);
  }

  // Confirmation dialog for deleting the task
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this task?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Changed from AppColors.danger
              ),
              child: const Text("Delete"),
              onPressed: () {
                widget.onDelete(widget.task.id);
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Go back to the previous screen
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Task"),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red), // Changed from AppColors.danger
            tooltip: "Delete Task",
            onPressed: _confirmDelete,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            _buildTextField(
              controller: _titleController,
              label: "Task Title",
              theme: theme,
              icon: Icons.title,
            ),
            const SizedBox(height: 16),

            // Description
            _buildTextField(
              controller: _descriptionController,
              label: "Description",
              theme: theme,
              maxLines: 3,
              icon: Icons.description,
            ),
            const SizedBox(height: 24),

            // Due Date
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: "Due Date:",
              value: _selectedDate != null
                  ? _selectedDate!.toLocal().toString().split(' ')[0]
                  : 'Not set',
              buttonLabel: "Change Date",
              onButtonPressed: _pickDate,
              clearButton: _selectedDate != null
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() => _selectedDate = null),
              )
                  : null,
            ),
            const SizedBox(height: 24),

            // Priority Selector
            _buildDropdownField(
              initialValue: _priority,
              label: "Priority",
              options: _priorityOptions,
              theme: theme,
              icon: Icons.priority_high,
              onChanged: (value) {
                if (value != null) setState(() => _priority = value);
              },
            ),
            const SizedBox(height: 24),

            // Completed Checkbox
            Row(
              children: [
                Checkbox(
                  value: _isCompleted,
                  onChanged: (value) {
                    if (value != null) setState(() => _isCompleted = value);
                  },
                  activeColor: AppColors.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const Text(
                  "Mark as Completed",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saveTask,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        AppConstants.defaultBorderRadius * 2),
                  ),
                ),
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  "Save Changes",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a styled TextField with an icon
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required ThemeData theme,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: theme.cardColor,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Helper method to build a styled info row with a button
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required String buttonLabel,
    required VoidCallback onButtonPressed,
    Widget? clearButton,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 14, color: Colors.black)), // Changed from AppColors.textLight
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        TextButton(
          onPressed: onButtonPressed,
          child: Text(buttonLabel, style: const TextStyle(color: AppColors.accent)),
        ),
        if (clearButton != null) clearButton,
      ],
    );
  }

  // Helper method to build a styled DropdownButtonFormField
  Widget _buildDropdownField({
    required String initialValue,
    required String label,
    required List<String> options,
    required ThemeData theme,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: initialValue, // Changed from value to initialValue
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: theme.cardColor,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: BorderSide.none,
        ),
      ),
      items: options
          .map((p) => DropdownMenuItem(
        value: p,
        child: Text(p),
      ))
          .toList(),
      onChanged: onChanged,
    );
  }
}