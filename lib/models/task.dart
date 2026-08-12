import 'priority.dart';
import 'subtask.dart';
import 'task_category.dart';

class Task {
  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.categoryId,
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.isCompleted = false,
    this.completedAt,
    DateTime? createdAt,
    List<SubTask>? subtasks,
    List<String>? tags,
    this.estimatedMinutes,
    this.isPinned = false,
  }) : createdAt = createdAt ?? DateTime.now(),
       subtasks = subtasks ?? <SubTask>[],
       tags = tags ?? <String>[];

  final String id;
  final String title;
  final String description;
  final String categoryId;
  final TaskPriority priority;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  final List<SubTask> subtasks;
  final List<String> tags;
  final int? estimatedMinutes;
  final bool isPinned;

  TaskCategory get category => TaskCategory.getById(categoryId);

  double get subtasksProgress {
    if (subtasks.isEmpty) {
      return isCompleted ? 1.0 : 0.0;
    }
    final int completedCount = subtasks
        .where((SubTask s) => s.isCompleted)
        .length;
    return completedCount / subtasks.length;
  }

  int get completedSubtasksCount =>
      subtasks.where((SubTask s) => s.isCompleted).length;

  bool get isOverdue {
    if (dueDate == null || isCompleted) {
      return false;
    }
    final DateTime now = DateTime.now();
    final DateTime todayStart = DateTime(now.year, now.month, now.day);
    final DateTime dueDayStart = DateTime(
      dueDate!.year,
      dueDate!.month,
      dueDate!.day,
    );
    return dueDayStart.isBefore(todayStart);
  }

  bool get isDueToday {
    if (dueDate == null) {
      return false;
    }
    final DateTime now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  bool get isDueTomorrow {
    if (dueDate == null) {
      return false;
    }
    final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
    return dueDate!.year == tomorrow.year &&
        dueDate!.month == tomorrow.month &&
        dueDate!.day == tomorrow.day;
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    TaskPriority? priority,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
    List<SubTask>? subtasks,
    List<String>? tags,
    int? estimatedMinutes,
    bool? isPinned,
    bool clearDueDate = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      priority: priority ?? this.priority,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      subtasks: subtasks ?? List<SubTask>.from(this.subtasks),
      tags: tags ?? List<String>.from(this.tags),
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}
