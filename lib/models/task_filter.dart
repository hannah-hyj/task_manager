import 'priority.dart';

enum TaskStatusFilter {
  all(label: 'All Tasks'),
  today(label: 'Today'),
  upcoming(label: 'Upcoming'),
  completed(label: 'Completed'),
  overdue(label: 'Overdue');

  const TaskStatusFilter({required this.label});
  final String label;
}

enum TaskSortBy {
  dueDate(label: 'Due Date'),
  priority(label: 'Priority'),
  createdAt(label: 'Created Date'),
  title(label: 'Alphabetical');

  const TaskSortBy({required this.label});
  final String label;
}

class TaskFilter {
  const TaskFilter({
    this.status = TaskStatusFilter.all,
    this.selectedCategoryId,
    this.selectedPriority,
    this.searchQuery = '',
    this.selectedTag,
    this.sortBy = TaskSortBy.dueDate,
    this.sortAscending = true,
    this.selectedDate,
  });

  final TaskStatusFilter status;
  final String? selectedCategoryId;
  final TaskPriority? selectedPriority;
  final String searchQuery;
  final String? selectedTag;
  final TaskSortBy sortBy;
  final bool sortAscending;
  final DateTime? selectedDate;

  bool get hasActiveFilters =>
      status != TaskStatusFilter.all ||
      selectedCategoryId != null ||
      selectedPriority != null ||
      searchQuery.trim().isNotEmpty ||
      selectedTag != null ||
      selectedDate != null;

  TaskFilter copyWith({
    TaskStatusFilter? status,
    String? selectedCategoryId,
    bool clearCategory = false,
    TaskPriority? selectedPriority,
    bool clearPriority = false,
    String? searchQuery,
    String? selectedTag,
    bool clearTag = false,
    TaskSortBy? sortBy,
    bool? sortAscending,
    DateTime? selectedDate,
    bool clearDate = false,
  }) {
    return TaskFilter(
      status: status ?? this.status,
      selectedCategoryId: clearCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      selectedPriority: clearPriority
          ? null
          : (selectedPriority ?? this.selectedPriority),
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTag: clearTag ? null : (selectedTag ?? this.selectedTag),
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      selectedDate: clearDate ? null : (selectedDate ?? this.selectedDate),
    );
  }
}
