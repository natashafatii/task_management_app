import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';
import '../widgets/loading_indicator.dart';
import '../constants/app_constants.dart';
import '../models/task_model.dart';
import 'task_detail_screen.dart';
import '../constants/app_colors.dart';

enum TaskFilter { all, pending, completed, highPriority }
enum SortOrder { dueDate, priority, title }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = "";
  TaskFilter _filter = TaskFilter.all;
  SortOrder _sortOrder = SortOrder.dueDate;

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    // ✅ Use theme colors
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final lowerCaseQuery = _searchQuery.toLowerCase();
    final filteredTasks = taskProvider.tasks.where((task) {
      final matchesSearch = task.title.toLowerCase().contains(lowerCaseQuery) ||
          task.description.toLowerCase().contains(lowerCaseQuery);
      final matchesFilter = _filter == TaskFilter.all ||
          (_filter == TaskFilter.pending && !task.isCompleted) ||
          (_filter == TaskFilter.completed && task.isCompleted) ||
          (_filter == TaskFilter.highPriority && task.priority == "High");
      return matchesSearch && matchesFilter;
    }).toList();

    filteredTasks.sort(_sortTasks);

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(
          'My Tasks',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: colors.onPrimary,
          ),
        ),
        centerTitle: false,
        backgroundColor: colors.primary,
        elevation: 0,
        toolbarHeight: 80,
        actions: [
          IconButton(
            icon: Icon(Icons.sort, color: colors.onPrimary),
            onPressed: _showSortOptions,
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: colors.onPrimary),
            onPressed: _showMoreOptions,
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.primary, colors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          setState(() {});
        },
        child: CustomScrollView(
          slivers: [
            // ✅ Stats
            Consumer<TaskProvider>(
              builder: (context, provider, child) {
                final totalTasks = provider.tasks.length;
                if (totalTasks == 0) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
                final completedTasks =
                    provider.tasks.where((task) => task.isCompleted).length;
                final pendingTasks = totalTasks - completedTasks;
                final highPriorityTasks = provider.tasks
                    .where((task) => task.priority == "High")
                    .length;
                return SliverToBoxAdapter(
                  child: _buildStatisticsCards(
                      totalTasks, completedTasks, pendingTasks, highPriorityTasks, colors),
                );
              },
            ),

            // ✅ Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                  vertical: 8,
                ),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: TextStyle(color: colors.onSurface),
                  decoration: InputDecoration(
                    hintText: "Search tasks...",
                    hintStyle: TextStyle(color: colors.onSurface.withOpacity(0.6)),
                    prefixIcon: Icon(Icons.search, color: colors.secondary),
                    filled: true,
                    fillColor: colors.primary.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear,
                          color: colors.onSurface.withOpacity(0.6)),
                      onPressed: () =>
                          setState(() => _searchQuery = ""),
                    )
                        : null,
                  ),
                ),
              ),
            ),

            // ✅ Filter chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding),
                  children: [
                    _buildFilterChip("All", TaskFilter.all, Icons.list, colors),
                    _buildFilterChip(
                        "Pending", TaskFilter.pending, Icons.pending_actions, colors),
                    _buildFilterChip(
                        "Completed", TaskFilter.completed, Icons.check_circle, colors),
                    _buildFilterChip("High Priority", TaskFilter.highPriority,
                        Icons.priority_high, colors),
                  ],
                ),
              ),
            ),

            // ✅ Sort info
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding),
                child: Row(
                  children: [
                    Icon(Icons.sort, size: 16, color: colors.onSurface.withOpacity(0.6)),
                    const SizedBox(width: 4),
                    Text(
                      "Sorted by: ${_getSortOrderText()}",
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurface.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // ✅ Task header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tasks (${filteredTasks.length})",
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: colors.onSurface,
                      ),
                    ),
                    if (filteredTasks.isNotEmpty)
                      TextButton(
                        onPressed: _clearCompleted,
                        child: Text(
                          "Clear Completed",
                          style: TextStyle(color: colors.secondary),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // ✅ Task list
            SliverPadding(
              padding: const EdgeInsets.only(
                left: AppConstants.defaultPadding,
                right: AppConstants.defaultPadding,
                top: AppConstants.defaultPadding,
                bottom: 80,
              ),
              sliver: Builder(
                builder: (_) {
                  if (taskProvider.isLoading) {
                    return const SliverFillRemaining(child: LoadingIndicator());
                  }

                  if (filteredTasks.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          "No tasks yet. Add your first task!",
                          style: TextStyle(
                              fontSize: 18,
                              color: colors.onSurface.withOpacity(0.6)),
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final task = filteredTasks[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: TaskTile(task: task),
                        );
                      },
                      childCount: filteredTasks.length,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TaskDetailScreen()),
          ),
          backgroundColor: colors.secondary,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                AppConstants.defaultBorderRadius * 2),
          ),
          icon: Icon(Icons.add, color: colors.onSecondary),
          label: Text("Add Task",
              style: TextStyle(color: colors.onSecondary)),
        ),
      ),
    );
  }

  int _sortTasks(Task a, Task b) {
    switch (_sortOrder) {
      case SortOrder.dueDate:
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return b.dueDate!.compareTo(a.dueDate!);
      case SortOrder.priority:
        final priorityOrder = {"High": 1, "Medium": 2, "Low": 3};
        return (priorityOrder[a.priority] ?? 4)
            .compareTo(priorityOrder[b.priority] ?? 4);
      case SortOrder.title:
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    }
  }

  String _getSortOrderText() {
    switch (_sortOrder) {
      case SortOrder.dueDate:
        return "Due Date";
      case SortOrder.priority:
        return "Priority";
      case SortOrder.title:
        return "Title";
    }
  }

  Widget _buildStatisticsCards(
      int total, int completed, int pending, int highPriority, ColorScheme colors) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding, vertical: 8),
      child: Row(
        children: [
          _buildAnimatedStatCard(
              "Total", total.toString(), Icons.list_alt, colors.primary, 0, colors),
          const SizedBox(width: 8),
          _buildAnimatedStatCard("Completed", completed.toString(),
              Icons.check_circle, Colors.green, 100, colors),
          const SizedBox(width: 8),
          _buildAnimatedStatCard("Pending", pending.toString(), Icons.pending,
              Colors.amber, 200, colors),
          const SizedBox(width: 8),
          _buildAnimatedStatCard("High Priority", highPriority.toString(),
              Icons.priority_high, Colors.red, 300, colors),
        ],
      ),
    );
  }

  Widget _buildAnimatedStatCard(
      String title, String value, IconData icon, Color color, int delay, ColorScheme colors) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOut,
      width: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.25), colors.primary],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colors.onPrimary, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.onPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: colors.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      String label, TaskFilter filter, IconData icon, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: _filter == filter,
        onSelected: (_) => setState(() => _filter = filter),
        backgroundColor: colors.primary.withOpacity(0.2),
        selectedColor: colors.primary,
        labelStyle: TextStyle(
          color: _filter == filter ? colors.onPrimary : colors.onSurface,
          fontWeight: _filter == filter ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
      ),
    );
  }
  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Sort by", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text("Due Date"),
              onTap: () {
                Navigator.pop(context);
                setState(() => _sortOrder = SortOrder.dueDate);
                _showSnackBar("Sorted by Due Date");
              },
            ),
            ListTile(
              leading: const Icon(Icons.priority_high),
              title: const Text("Priority"),
              onTap: () {
                Navigator.pop(context);
                setState(() => _sortOrder = SortOrder.priority);
                _showSnackBar("Sorted by Priority");
              },
            ),
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text("Title"),
              onTap: () {
                Navigator.pop(context);
                setState(() => _sortOrder = SortOrder.title);
                _showSnackBar("Sorted by Title");
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              "More Options",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.delete_sweep),
              title: const Text("Clear All Completed"),
              onTap: () {
                Navigator.pop(context);
                _clearCompleted();
              },
            ),
            ListTile(
              leading: const Icon(Icons.import_export),
              title: const Text("Export Tasks"),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar("Export feature coming soon!");
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_active, color: AppColors.info),
              title: const Text("Notification Settings"),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar("Notification settings coming soon!");
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info, color: AppColors.textSecondary),
              title: const Text("About"),
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("About Task Manager"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("A beautiful task management app built with Flutter."),
            SizedBox(height: 8),
            Text("Features:"),
            Text("• Create, edit, delete tasks"),
            Text("• Filter by status and priority"),
            Text("• Search functionality"),
            Text("• Statistics and analytics"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCompleted() async {
    if (!mounted) return;
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final completedTasks = taskProvider.tasks.where((task) => task.isCompleted).toList();
    if (completedTasks.isEmpty) {
      _showSnackBar("No completed tasks to clear");
      return;
    }
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear Completed Tasks"),
        content: Text("Are you sure you want to clear ${completedTasks.length} completed tasks?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text("Clear All"),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (shouldClear ?? false) {
      for (final task in completedTasks) {
        taskProvider.deleteTask(task.id);
      }
      _showSnackBar("Cleared ${completedTasks.length} completed tasks");
    }
  }

  Future<bool> _confirmDelete(String taskTitle) async {
    if (!mounted) return false;
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Task"),
        content: Text("Are you sure you want to delete \"$taskTitle\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text("Delete"),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}