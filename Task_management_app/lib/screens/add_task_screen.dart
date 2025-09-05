import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../utils/validators.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? taskToEdit;

  const AddTaskScreen({super.key, this.taskToEdit});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;
  bool _isDirty = false;

  String _priority = AppConstants.defaultPriority;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      _titleController.text = widget.taskToEdit!.title;
      _descriptionController.text = widget.taskToEdit!.description;
      _priority = widget.taskToEdit!.priority;
      _dueDate = widget.taskToEdit!.dueDate;
      if (_dueDate != null) {
        _dueTime = TimeOfDay.fromDateTime(_dueDate!);
      }
      _isDirty = false;
    }
  }

  void _handleNavigation(bool didPop, Object? result) {
    if (_isDirty && !_isSubmitting) {
      _showDiscardDialog().then((shouldLeave) {
        if (shouldLeave ?? false) {
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      });
    } else {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<bool?> _showDiscardDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('You have unsaved changes. Do you really want to leave?'),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.taskToEdit != null;
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _handleNavigation,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            isEditing ? 'Edit Task' : 'Create New Task',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: colorScheme.onPrimary,
            ),
          ),
          centerTitle: true,
          backgroundColor: colorScheme.primary,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onPrimary, size: 22),
            onPressed: () => _handleNavigation(false, null),
          ),
          actions: [
            if (isEditing)
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: colorScheme.onPrimary),
                onPressed: _showDeleteConfirmation,
              ),
          ],
        ),
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              children: [
                // Header with decorative elements
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.85)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isEditing ? Icons.edit_rounded : Icons.add_task_rounded,
                        size: 32,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        Form(
                          key: _formKey,
                          onChanged: () => setState(() => _isDirty = true),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildSectionHeader('Task Details'),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _titleController,
                                hint: 'What needs to be done?',
                                label: 'Title',
                                icon: Icons.title_rounded,
                                validator: Validators.validateTitle,
                                autoFocus: true,
                                textCapitalization: TextCapitalization.sentences,
                                inputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _descriptionController,
                                hint: 'Add details about this task...',
                                label: 'Description (Optional)',
                                icon: Icons.description_rounded,
                                validator: Validators.validateDescription,
                                maxLines: 4,
                                inputAction: TextInputAction.done,
                              ),
                              const SizedBox(height: 24),
                              _buildSectionHeader('Task Settings'),
                              const SizedBox(height: 16),
                              _buildLabel('Priority Level'),
                              const SizedBox(height: 8),
                              _buildPriorityDropdown(),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel('Due Date'),
                                        const SizedBox(height: 8),
                                        _buildDatePickerField(),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel('Time (Optional)'),
                                        const SizedBox(height: 8),
                                        _buildTimePickerField(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              _buildActionButtons(isEditing),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool autoFocus = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction inputAction = TextInputAction.done,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        autofocus: autoFocus,
        textCapitalization: textCapitalization,
        textInputAction: inputAction,
        style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: colorScheme.primary),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
          filled: true,
          fillColor: colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
          hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
        ),
      ),
    );
  }

  Widget _buildPriorityDropdown() {
    final colorScheme = Theme.of(context).colorScheme;
    return DropdownButtonFormField<String>(
      initialValue: _priority,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.flag_rounded, color: colorScheme.primary),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      items: AppConstants.taskPriorities
          .map((p) => DropdownMenuItem<String>(
        value: p,
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _getPriorityColor(p).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                p == "High"
                    ? Icons.keyboard_double_arrow_up_rounded
                    : p == "Medium"
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_double_arrow_down_rounded,
                color: _getPriorityColor(p),
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Text(p, style: TextStyle(color: colorScheme.onSurface)),
          ],
        ),
      ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _priority = value!;
          _isDirty = true;
        });
      },
      style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
    );
  }

  Widget _buildDatePickerField() {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: _pickDueDate,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _dueDate == null
                    ? 'Select date'
                    : DateFormat('EEE, MMM d').format(_dueDate!),
                style: TextStyle(
                  fontSize: 16,
                  color: _dueDate == null
                      ? colorScheme.onSurface.withOpacity(0.5)
                      : colorScheme.onSurface,
                ),
              ),
            ),
            if (_dueDate != null)
              IconButton(
                icon: Icon(Icons.clear_rounded, color: colorScheme.onSurface.withOpacity(0.5), size: 20),
                onPressed: () => setState(() {
                  _dueDate = null;
                  _dueTime = null;
                }),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerField() {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: _dueDate == null ? null : _pickDueTime,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: _dueDate == null ? colorScheme.surface.withOpacity(0.3) : colorScheme.surface,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time_rounded,
                color: _dueDate == null ? colorScheme.onSurface.withOpacity(0.4) : colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _dueTime == null ? 'Select time' : _dueTime!.format(context),
                style: TextStyle(
                  fontSize: 16,
                  color: _dueTime == null ? colorScheme.onSurface.withOpacity(0.5) : colorScheme.onSurface,
                ),
              ),
            ),
            if (_dueTime != null)
              IconButton(
                icon: Icon(Icons.clear_rounded, color: colorScheme.onSurface.withOpacity(0.5), size: 20),
                onPressed: () => setState(() => _dueTime = null),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool isEditing) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : () => _saveTask(isEditing),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              elevation: 3,
            ),
            child: _isSubmitting
                ? SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(colorScheme.onPrimary),
              ),
            )
                : Text(
              isEditing ? 'UPDATE TASK' : 'CREATE TASK',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => _handleNavigation(false, null),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            'CANCEL',
            style: TextStyle(
              fontSize: 15,
              color: colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null && mounted) {
      setState(() {
        _dueDate = picked;
        _dueTime ??= const TimeOfDay(hour: 23, minute: 59);
      });
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _pickDueTime() async {
    if (_dueDate == null) return;

    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );

    if (picked != null && mounted) {
      setState(() => _dueTime = picked);
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _saveTask(bool isEditing) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    final title = _titleController.text;
    final description = _descriptionController.text;
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    try {
      DateTime? combinedDueDate;
      if (_dueDate != null) {
        if (_dueTime != null) {
          combinedDueDate = DateTime(
            _dueDate!.year,
            _dueDate!.month,
            _dueDate!.day,
            _dueTime!.hour,
            _dueTime!.minute,
          );
        } else {
          combinedDueDate = _dueDate;
        }
      }

      if (isEditing) {
        final updatedTask = widget.taskToEdit!.copyWith(
          title: title,
          description: description,
          priority: _priority,
          dueDate: combinedDueDate,
        );
        await taskProvider.updateTask(updatedTask);
      } else {
        final task = Task(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          description: description,
          createdAt: DateTime.now(),
          priority: _priority,
          dueDate: combinedDueDate,
        );
        await taskProvider.addTask(task);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Task updated successfully!' : 'Task created successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error ${isEditing ? 'updating' : 'creating'} task: $error'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task?'),
        content: const Text('Are you sure you want to delete this task? This action cannot be undone.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTask();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTask() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    try {
      await taskProvider.deleteTask(widget.taskToEdit!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Task deleted successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting task: $error'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return AppColors.error;
      case 'Medium':
        return AppColors.warning;
      case 'Low':
      default:
        return AppColors.success;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}