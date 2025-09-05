import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../constants/app_colors.dart';
import '../screens/task_detail_screen.dart';

class TaskTile extends StatelessWidget {
  final Task task;

  const TaskTile({
    super.key,
    required this.task,
  });

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
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(task.priority);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      // Dim the card if the task is completed
      color: task.isCompleted ? AppColors.surface : Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(task: task),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              // Task completion icon
              _buildCompletionIcon(context),

              const SizedBox(width: 16),

              // Task details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: task.isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (task.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          task.description,
                          style: TextStyle(
                            color: task.isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 4),
                    _buildPriorityAndDueDateInfo(priorityColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionIcon(BuildContext context) {
    return InkWell(
      onTap: () {
        final taskProvider = Provider.of<TaskProvider>(context, listen: false);
        final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
        taskProvider.updateTask(updatedTask);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: task.isCompleted ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: task.isCompleted ? AppColors.primary : AppColors.textSecondary,
            width: 2,
          ),
        ),
        child: task.isCompleted
            ? const Icon(
          Icons.check,
          color: Colors.white,
          size: 20,
        )
            : null,
      ),
    );
  }

  Widget _buildPriorityAndDueDateInfo(Color priorityColor) {
    return Row(
      children: [
        if (task.dueDate != null)
          _buildInfoChip(
            "Due: ${DateFormat.yMMMd().format(task.dueDate!)}",
            Icons.calendar_today,
            AppColors.textSecondary,
          ),
        if (task.dueDate != null)
          const SizedBox(width: 8),
        _buildInfoChip(
          "Priority: ${task.priority}",
          Icons.circle,
          priorityColor,
          iconSize: 10,
        ),
      ],
    );
  }

  Widget _buildInfoChip(String label, IconData icon, Color color, {double iconSize = 12}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}