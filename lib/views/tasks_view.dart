import 'package:flutter/material.dart';

import '../controllers/task_controller.dart';
import '../models/task.dart';
import '../models/task_category.dart';
import '../models/task_filter.dart';
import '../widgets/add_edit_task_sheet.dart';
import '../widgets/category_chip.dart';
import '../widgets/filter_drawer.dart';
import '../widgets/stats_card.dart';
import '../widgets/task_card.dart';
import '../widgets/task_details_sheet.dart';

class TasksView extends StatefulWidget {
  const TasksView({super.key, required this.controller});

  final TaskController controller;

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAddTaskSheet({String? categoryId, DateTime? date}) async {
    final Task? newTask = await showModalBottomSheet<Task>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext ctx) =>
          AddEditTaskSheet(initialCategoryId: categoryId, initialDate: date),
    );

    if (newTask != null) {
      widget.controller.addTask(newTask);
    }
  }

  void _openTaskDetails(String taskId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext ctx) =>
          TaskDetailsSheet(taskId: taskId, controller: widget.controller),
    );
  }

  void _openFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext ctx) =>
          FilterBottomSheet(controller: widget.controller),
    );
  }

  String _getGreeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning ☀️';
    } else if (hour < 17) {
      return 'Good afternoon 🌤️';
    } else {
      return 'Good evening 🌙';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (BuildContext context, Widget? child) {
        final List<Task> tasks = widget.controller.filteredTasks;
        final TaskFilter filter = widget.controller.filter;

        return Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              // App Bar with Greeting and Actions
              SliverAppBar(
                floating: true,
                snap: true,
                pinned: false,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white60
                            : const Color(0xFF64748B),
                      ),
                    ),
                    const Text(
                      'Task Studio',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                actions: <Widget>[
                  IconButton(
                    tooltip: 'Search tasks',
                    icon: Icon(
                      _isSearchVisible
                          ? Icons.search_off_rounded
                          : Icons.search_rounded,
                    ),
                    onPressed: () {
                      setState(() {
                        _isSearchVisible = !_isSearchVisible;
                        if (!_isSearchVisible) {
                          _searchController.clear();
                          widget.controller.setSearchQuery('');
                        }
                      });
                    },
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      IconButton(
                        tooltip: 'Filter & Sort',
                        icon: const Icon(Icons.tune_rounded),
                        onPressed: _openFilterSheet,
                      ),
                      if (filter.hasActiveFilters)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              // Search Bar (if expanded)
              if (_isSearchVisible)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search tasks, tags, descriptions...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  widget.controller.setSearchQuery('');
                                },
                              )
                            : null,
                      ),
                      onChanged: (String query) {
                        widget.controller.setSearchQuery(query);
                      },
                    ),
                  ),
                ),

              // Quick Stats Banner
              SliverToBoxAdapter(
                child: QuickStatsOverview(
                  totalTasks: widget.controller.totalCount,
                  completedTasks: widget.controller.completedCount,
                  completionRate: widget.controller.completionRate,
                  completedToday: widget.controller.completedTodayCount,
                  overdueCount: widget.controller.overdueCount,
                  streakDays: widget.controller.streakDays,
                ),
              ),

              // Categories Horizontal Scroll List
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: <Widget>[
                        CategoryChip(
                          category: null,
                          isSelected: filter.selectedCategoryId == null,
                          taskCount: widget.controller.totalCount,
                          onTap: () =>
                              widget.controller.setCategoryFilter(null),
                        ),
                        ...TaskCategory.defaultCategories.map((
                          TaskCategory cat,
                        ) {
                          final int? count =
                              widget.controller.categoryTaskCounts[cat];
                          return CategoryChip(
                            category: cat,
                            isSelected: filter.selectedCategoryId == cat.id,
                            taskCount: count,
                            onTap: () =>
                                widget.controller.setCategoryFilter(cat.id),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),

              // Status Filter Tabs (All, Today, Upcoming, Completed)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: TaskStatusFilter.values.map((
                        TaskStatusFilter status,
                      ) {
                        final bool isSelected = filter.status == status;
                        int count = 0;
                        switch (status) {
                          case TaskStatusFilter.all:
                            count = widget.controller.totalCount;
                          case TaskStatusFilter.today:
                            count = widget.controller.dueTodayCount;
                          case TaskStatusFilter.upcoming:
                            count = widget.controller.allTasks
                                .where(
                                  (Task t) =>
                                      !t.isCompleted &&
                                      t.dueDate != null &&
                                      !t.isDueToday &&
                                      !t.isOverdue,
                                )
                                .length;
                          case TaskStatusFilter.completed:
                            count = widget.controller.completedCount;
                          case TaskStatusFilter.overdue:
                            count = widget.controller.overdueCount;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text('${status.label} ($count)'),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              if (selected) {
                                widget.controller.setStatusFilter(status);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // Tasks List or Empty State
              if (tasks.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.task_alt_rounded,
                              size: 48,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            filter.hasActiveFilters
                                ? 'No matching tasks'
                                : 'All clear for now!',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            filter.hasActiveFilters
                                ? 'Try adjusting your filters or search query'
                                : 'Tap the button below to add your next goal',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.white60
                                  : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (filter.hasActiveFilters)
                            OutlinedButton.icon(
                              onPressed: () {
                                _searchController.clear();
                                widget.controller.resetFilters();
                              },
                              icon: const Icon(Icons.filter_alt_off_rounded),
                              label: const Text('Clear Filters'),
                            )
                          else
                            FilledButton.icon(
                              onPressed: () => _openAddTaskSheet(
                                categoryId: filter.selectedCategoryId,
                              ),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Add a Task'),
                            ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((
                    BuildContext context,
                    int index,
                  ) {
                    final Task task = tasks[index];
                    return TaskCard(
                      task: task,
                      onToggleComplete: () =>
                          widget.controller.toggleTaskCompletion(task.id),
                      onTap: () => _openTaskDetails(task.id),
                      onDelete: () => widget.controller.deleteTask(task.id),
                      onTogglePin: () =>
                          widget.controller.togglePinTask(task.id),
                      onDuplicate: () =>
                          widget.controller.duplicateTask(task.id),
                    );
                  }, childCount: tasks.length),
                ),

              // Bottom spacing for FloatingActionButton
              const SliverToBoxAdapter(child: SizedBox(height: 90)),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () =>
                _openAddTaskSheet(categoryId: filter.selectedCategoryId),
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Add Task',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        );
      },
    );
  }
}
