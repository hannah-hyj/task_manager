import 'package:flutter/material.dart';

import '../models/priority.dart';
import '../models/subtask.dart';
import '../models/task.dart';
import '../models/task_category.dart';
import '../models/task_filter.dart';

class TaskController extends ChangeNotifier {
  TaskController({List<Task>? initialTasks}) {
    _tasks = initialTasks ?? _createInitialTasks();
  }

  late List<Task> _tasks;
  TaskFilter _filter = const TaskFilter();

  List<Task> get allTasks => List<Task>.unmodifiable(_tasks);
  TaskFilter get filter => _filter;

  // --- Filtering & Sorting ---

  List<Task> get filteredTasks {
    List<Task> result = _tasks.where((Task task) {
      // Search filter
      if (_filter.searchQuery.trim().isNotEmpty) {
        final String query = _filter.searchQuery.toLowerCase().trim();
        final bool titleMatch = task.title.toLowerCase().contains(query);
        final bool descMatch = task.description.toLowerCase().contains(query);
        final bool tagMatch = task.tags.any(
          (String t) => t.toLowerCase().contains(query),
        );
        if (!titleMatch && !descMatch && !tagMatch) {
          return false;
        }
      }

      // Category filter
      if (_filter.selectedCategoryId != null &&
          task.categoryId != _filter.selectedCategoryId) {
        return false;
      }

      // Priority filter
      if (_filter.selectedPriority != null &&
          task.priority != _filter.selectedPriority) {
        return false;
      }

      // Tag filter
      if (_filter.selectedTag != null &&
          !task.tags.contains(_filter.selectedTag)) {
        return false;
      }

      // Date filter (specific calendar date)
      if (_filter.selectedDate != null) {
        if (task.dueDate == null) {
          return false;
        }
        final DateTime target = _filter.selectedDate!;
        final bool sameDay =
            task.dueDate!.year == target.year &&
            task.dueDate!.month == target.month &&
            task.dueDate!.day == target.day;
        if (!sameDay) {
          return false;
        }
      }

      // Status filter
      switch (_filter.status) {
        case TaskStatusFilter.all:
          return true;
        case TaskStatusFilter.today:
          return task.isDueToday && !task.isCompleted;
        case TaskStatusFilter.upcoming:
          if (task.isCompleted || task.dueDate == null) return false;
          final DateTime now = DateTime.now();
          final DateTime todayEnd = DateTime(
            now.year,
            now.month,
            now.day,
            23,
            59,
            59,
          );
          return task.dueDate!.isAfter(todayEnd);
        case TaskStatusFilter.completed:
          return task.isCompleted;
        case TaskStatusFilter.overdue:
          return task.isOverdue;
      }
    }).toList();

    // Sort: pinned items always come first within matching groups
    result.sort((Task a, Task b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }

      int cmp = 0;
      switch (_filter.sortBy) {
        case TaskSortBy.dueDate:
          if (a.dueDate == null && b.dueDate == null) {
            cmp = 0;
          } else if (a.dueDate == null) {
            cmp = 1;
          } else if (b.dueDate == null) {
            cmp = -1;
          } else {
            cmp = a.dueDate!.compareTo(b.dueDate!);
          }
        case TaskSortBy.priority:
          cmp = b.priority.level.compareTo(a.priority.level);
        case TaskSortBy.createdAt:
          cmp = b.createdAt.compareTo(a.createdAt);
        case TaskSortBy.title:
          cmp = a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }
      return _filter.sortAscending ? cmp : -cmp;
    });

    return result;
  }

  // --- Statistics & Metrics ---

  int get totalCount => _tasks.length;
  int get completedCount => _tasks.where((Task t) => t.isCompleted).length;
  int get pendingCount => _tasks.where((Task t) => !t.isCompleted).length;

  double get completionRate =>
      totalCount == 0 ? 0.0 : (completedCount / totalCount);

  int get dueTodayCount =>
      _tasks.where((Task t) => t.isDueToday && !t.isCompleted).length;

  int get overdueCount => _tasks.where((Task t) => t.isOverdue).length;

  int get completedTodayCount {
    final DateTime now = DateTime.now();
    return _tasks.where((Task t) {
      if (!t.isCompleted || t.completedAt == null) return false;
      return t.completedAt!.year == now.year &&
          t.completedAt!.month == now.month &&
          t.completedAt!.day == now.day;
    }).length;
  }

  int get completedThisWeekCount {
    final DateTime now = DateTime.now();
    final DateTime weekAgo = now.subtract(const Duration(days: 7));
    return _tasks.where((Task t) {
      if (!t.isCompleted || t.completedAt == null) return false;
      return t.completedAt!.isAfter(weekAgo);
    }).length;
  }

  int get streakDays {
    if (_tasks.isEmpty) return 0;
    int streak = 0;
    final DateTime now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final DateTime day = now.subtract(Duration(days: i));
      final bool hadCompletion = _tasks.any((Task t) {
        if (!t.isCompleted || t.completedAt == null) return false;
        return t.completedAt!.year == day.year &&
            t.completedAt!.month == day.month &&
            t.completedAt!.day == day.day;
      });
      if (hadCompletion) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }

  Set<String> get allTags {
    final Set<String> tags = <String>{};
    for (final Task task in _tasks) {
      tags.addAll(task.tags);
    }
    return tags;
  }

  Map<TaskCategory, int> get categoryTaskCounts {
    final Map<TaskCategory, int> counts = <TaskCategory, int>{};
    for (final TaskCategory cat in TaskCategory.defaultCategories) {
      counts[cat] = _tasks.where((Task t) => t.categoryId == cat.id).length;
    }
    return counts;
  }

  Map<TaskCategory, double> get categoryCompletionRates {
    final Map<TaskCategory, double> rates = <TaskCategory, double>{};
    for (final TaskCategory cat in TaskCategory.defaultCategories) {
      final List<Task> catTasks = _tasks
          .where((Task t) => t.categoryId == cat.id)
          .toList();
      if (catTasks.isEmpty) {
        rates[cat] = 0.0;
      } else {
        final int done = catTasks.where((Task t) => t.isCompleted).length;
        rates[cat] = done / catTasks.length;
      }
    }
    return rates;
  }

  Map<TaskPriority, int> get priorityTaskCounts {
    final Map<TaskPriority, int> counts = <TaskPriority, int>{};
    for (final TaskPriority p in TaskPriority.values) {
      counts[p] = _tasks
          .where((Task t) => t.priority == p && !t.isCompleted)
          .length;
    }
    return counts;
  }

  Map<DateTime, int> get dailyCompletionsLast7Days {
    final Map<DateTime, int> result = <DateTime, int>{};
    final DateTime now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final DateTime day = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      final int count = _tasks.where((Task t) {
        if (!t.isCompleted || t.completedAt == null) return false;
        final DateTime c = t.completedAt!;
        return c.year == day.year && c.month == day.month && c.day == day.day;
      }).length;
      result[day] = count;
    }
    return result;
  }

  // --- CRUD Operations ---

  void addTask(Task task) {
    _tasks.insert(0, task);
    notifyListeners();
  }

  void updateTask(Task updatedTask) {
    final int index = _tasks.indexWhere((Task t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }

  void toggleTaskCompletion(String taskId) {
    final int index = _tasks.indexWhere((Task t) => t.id == taskId);
    if (index != -1) {
      final Task task = _tasks[index];
      final bool newCompleted = !task.isCompleted;
      final List<SubTask> updatedSubtasks = task.subtasks
          .map((SubTask s) => s.copyWith(isCompleted: newCompleted))
          .toList();

      _tasks[index] = task.copyWith(
        isCompleted: newCompleted,
        completedAt: newCompleted ? DateTime.now() : null,
        subtasks: updatedSubtasks,
      );
      notifyListeners();
    }
  }

  void toggleSubTaskCompletion(String taskId, String subtaskId) {
    final int taskIndex = _tasks.indexWhere((Task t) => t.id == taskId);
    if (taskIndex != -1) {
      final Task task = _tasks[taskIndex];
      final List<SubTask> updatedSubtasks = task.subtasks.map((SubTask s) {
        if (s.id == subtaskId) {
          return s.copyWith(isCompleted: !s.isCompleted);
        }
        return s;
      }).toList();

      final bool allSubtasksDone =
          updatedSubtasks.isNotEmpty &&
          updatedSubtasks.every((SubTask s) => s.isCompleted);

      _tasks[taskIndex] = task.copyWith(
        subtasks: updatedSubtasks,
        isCompleted: allSubtasksDone,
        completedAt: allSubtasksDone ? DateTime.now() : null,
      );
      notifyListeners();
    }
  }

  void addSubTask(String taskId, String title) {
    final int taskIndex = _tasks.indexWhere((Task t) => t.id == taskId);
    if (taskIndex != -1 && title.trim().isNotEmpty) {
      final Task task = _tasks[taskIndex];
      final SubTask newSub = SubTask(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title.trim(),
      );
      _tasks[taskIndex] = task.copyWith(
        subtasks: <SubTask>[...task.subtasks, newSub],
        isCompleted: false,
      );
      notifyListeners();
    }
  }

  void removeSubTask(String taskId, String subtaskId) {
    final int taskIndex = _tasks.indexWhere((Task t) => t.id == taskId);
    if (taskIndex != -1) {
      final Task task = _tasks[taskIndex];
      final List<SubTask> updated = task.subtasks
          .where((SubTask s) => s.id != subtaskId)
          .toList();
      _tasks[taskIndex] = task.copyWith(subtasks: updated);
      notifyListeners();
    }
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((Task t) => t.id == taskId);
    notifyListeners();
  }

  void togglePinTask(String taskId) {
    final int index = _tasks.indexWhere((Task t) => t.id == taskId);
    if (index != -1) {
      final Task task = _tasks[index];
      _tasks[index] = task.copyWith(isPinned: !task.isPinned);
      notifyListeners();
    }
  }

  void duplicateTask(String taskId) {
    final int index = _tasks.indexWhere((Task t) => t.id == taskId);
    if (index != -1) {
      final Task original = _tasks[index];
      final Task copy = original.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: '${original.title} (Copy)',
        isCompleted: false,
        completedAt: null,
        createdAt: DateTime.now(),
        subtasks: original.subtasks
            .map(
              (SubTask s) => SubTask(
                id: '${s.id}_copy_${DateTime.now().millisecondsSinceEpoch}',
                title: s.title,
                isCompleted: false,
              ),
            )
            .toList(),
      );
      _tasks.insert(index + 1, copy);
      notifyListeners();
    }
  }

  void clearCompletedTasks() {
    _tasks.removeWhere((Task t) => t.isCompleted);
    notifyListeners();
  }

  void resetSampleData() {
    _tasks = _createInitialTasks();
    notifyListeners();
  }

  // --- Filter Updates ---

  void setStatusFilter(TaskStatusFilter status) {
    _filter = _filter.copyWith(status: status);
    notifyListeners();
  }

  void setCategoryFilter(String? categoryId) {
    if (categoryId == null) {
      _filter = _filter.copyWith(clearCategory: true);
    } else {
      _filter = _filter.copyWith(selectedCategoryId: categoryId);
    }
    notifyListeners();
  }

  void setPriorityFilter(TaskPriority? priority) {
    if (priority == null) {
      _filter = _filter.copyWith(clearPriority: true);
    } else {
      _filter = _filter.copyWith(selectedPriority: priority);
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _filter = _filter.copyWith(searchQuery: query);
    notifyListeners();
  }

  void setSelectedTag(String? tag) {
    if (tag == null) {
      _filter = _filter.copyWith(clearTag: true);
    } else {
      _filter = _filter.copyWith(selectedTag: tag);
    }
    notifyListeners();
  }

  void setSelectedDate(DateTime? date) {
    if (date == null) {
      _filter = _filter.copyWith(clearDate: true);
    } else {
      _filter = _filter.copyWith(selectedDate: date);
    }
    notifyListeners();
  }

  void setSort(TaskSortBy sortBy, {bool? ascending}) {
    _filter = _filter.copyWith(
      sortBy: sortBy,
      sortAscending:
          ascending ??
          (_filter.sortBy == sortBy ? !_filter.sortAscending : true),
    );
    notifyListeners();
  }

  void resetFilters() {
    _filter = const TaskFilter();
    notifyListeners();
  }

  // --- Initial Seed Data ---

  static List<Task> _createInitialTasks() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime tomorrow = today.add(const Duration(days: 1));
    final DateTime nextWeek = today.add(const Duration(days: 4));
    final DateTime yesterday = today.subtract(const Duration(days: 1));

    return <Task>[
      Task(
        id: '1',
        title: 'Design Design System & Accessibility Audit',
        description: 'Complete WCAG 2.2 AA review, color contrast checks, and component tokens for the next release.',
        categoryId: 'design',
        priority: TaskPriority.urgent,
        dueDate: today.add(const Duration(hours: 17)),
        isPinned: true,
        estimatedMinutes: 90,
        tags: <String>['UI/UX', 'Accessibility', 'v2.0'],
        subtasks: <SubTask>[
          SubTask(
            id: 's1-1',
            title: 'Audit color contrast ratios for dark theme',
            isCompleted: true,
          ),
          SubTask(
            id: 's1-2',
            title: 'Verify screen reader announcements and semantic labels',
            isCompleted: true,
          ),
          SubTask(
            id: 's1-3',
            title: 'Export Figma token variables to Flutter theme',
            isCompleted: false,
          ),
          SubTask(
            id: 's1-4',
            title: 'Conduct keyboard focus order testing',
            isCompleted: false,
          ),
        ],
      ),
      Task(
        id: '2',
        title: 'Implement Task Analytics & Weekly Chart',
        description: 'Build interactive productivity graphs and progress rings with responsive layout.',
        categoryId: 'development',
        priority: TaskPriority.high,
        dueDate: today.add(const Duration(hours: 20)),
        isPinned: true,
        estimatedMinutes: 60,
        tags: <String>['Feature', 'Flutter', 'Analytics'],
        subtasks: <SubTask>[
          SubTask(
            id: 's2-1',
            title: 'Compute 7-day completion velocity',
            isCompleted: true,
          ),
          SubTask(
            id: 's2-2',
            title: 'Create animated progress indicators',
            isCompleted: true,
          ),
        ],
      ),
      Task(
        id: '3',
        title: 'Q3 Product Roadmap Review',
        description: 'Sync with product stakeholders on deliverables, milestones, and release targets.',
        categoryId: 'work',
        priority: TaskPriority.high,
        dueDate: tomorrow.add(const Duration(hours: 14)),
        estimatedMinutes: 45,
        tags: <String>['Strategy', 'Roadmap'],
        subtasks: <SubTask>[
          SubTask(
            id: 's3-1',
            title: 'Draft presentation slide deck',
            isCompleted: false,
          ),
          SubTask(
            id: 's3-2',
            title: 'Gather engineering capacity estimates',
            isCompleted: false,
          ),
        ],
      ),
      Task(
        id: '4',
        title: '5km Morning Run & Stretch',
        description: 'Maintain cardio routine in the park followed by full-body recovery stretch.',
        categoryId: 'fitness',
        priority: TaskPriority.medium,
        dueDate: today.add(const Duration(hours: 8)),
        isCompleted: true,
        completedAt: today.add(const Duration(hours: 8, minutes: 30)),
        estimatedMinutes: 40,
        tags: <String>['Cardio', 'Health'],
        subtasks: <SubTask>[
          SubTask(id: 's4-1', title: '5km running route', isCompleted: true),
          SubTask(
            id: 's4-2',
            title: '10 min stretch & hydration',
            isCompleted: true,
          ),
        ],
      ),
      Task(
        id: '5',
        title: 'Read Dart 3.14 & Flutter Architecture Specs',
        description: 'Study latest language enhancements, macro patterns, and rendering optimizations.',
        categoryId: 'study',
        priority: TaskPriority.low,
        dueDate: nextWeek,
        estimatedMinutes: 60,
        tags: <String>['Dart', 'Learning'],
        subtasks: <SubTask>[
          SubTask(
            id: 's5-1',
            title: 'Read compiler release notes',
            isCompleted: false,
          ),
          SubTask(
            id: 's5-2',
            title: 'Explore new platform channel features',
            isCompleted: false,
          ),
        ],
      ),
      Task(
        id: '6',
        title: 'Review Monthly Budget & Investments',
        description: 'Reconcile cloud subscription invoices and allocate savings budget.',
        categoryId: 'finance',
        priority: TaskPriority.medium,
        dueDate: yesterday,
        isCompleted: false, // Overdue task demo
        estimatedMinutes: 30,
        tags: <String>['Finances', 'Personal'],
        subtasks: <SubTask>[
          SubTask(
            id: 's6-1',
            title: 'Categorize receipts in spreadsheet',
            isCompleted: false,
          ),
          SubTask(
            id: 's6-2',
            title: 'Check recurring subscription fees',
            isCompleted: false,
          ),
        ],
      ),
      Task(
        id: '7',
        title: 'Organize Workspace & Desk Setup',
        description: 'Cable management, clean monitor, and set up ergonomic keyboard layout.',
        categoryId: 'personal',
        priority: TaskPriority.low,
        dueDate: today.subtract(const Duration(days: 2)),
        isCompleted: true,
        completedAt: today.subtract(const Duration(days: 2, hours: 3)),
        estimatedMinutes: 25,
        tags: <String>['Lifestyle'],
      ),
      Task(
        id: '8',
        title: 'Submit Expense Reports',
        description:
            'Upload hotel and travel expense receipts for the team conference.',
        categoryId: 'work',
        priority: TaskPriority.medium,
        dueDate: today.subtract(const Duration(days: 3)),
        isCompleted: true,
        completedAt: today.subtract(const Duration(days: 3, hours: 5)),
        estimatedMinutes: 15,
        tags: <String>['Admin'],
      ),
    ];
  }
}
