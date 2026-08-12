import 'package:flutter/material.dart';

import '../controllers/task_controller.dart';
import '../models/priority.dart';
import '../models/task_category.dart';
import '../models/task_filter.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key, required this.controller});

  final TaskController controller;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final TaskFilter filter = controller.filter;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Filter & Sort',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                TextButton(
                  onPressed: () {
                    controller.resetFilters();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Reset All'),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Status Filter
            const Text(
              'Status',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: TaskStatusFilter.values.map((TaskStatusFilter status) {
                final bool isSelected = filter.status == status;
                return ChoiceChip(
                  label: Text(status.label),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    if (selected) {
                      controller.setStatusFilter(status);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Sort By
            const Text(
              'Sort By',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: TaskSortBy.values.map((TaskSortBy sortBy) {
                final bool isSelected = filter.sortBy == sortBy;
                return FilterChip(
                  avatar: isSelected
                      ? Icon(
                          filter.sortAscending
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 16,
                        )
                      : null,
                  label: Text(sortBy.label),
                  selected: isSelected,
                  onSelected: (_) {
                    controller.setSort(sortBy);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Category Filter
            const Text(
              'Category',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                ChoiceChip(
                  label: const Text('All Categories'),
                  selected: filter.selectedCategoryId == null,
                  onSelected: (bool selected) {
                    if (selected) controller.setCategoryFilter(null);
                  },
                ),
                ...TaskCategory.defaultCategories.map((TaskCategory cat) {
                  final bool isSelected = filter.selectedCategoryId == cat.id;
                  return ChoiceChip(
                    avatar: Icon(
                      cat.icon,
                      size: 16,
                      color: isSelected ? Colors.white : cat.color,
                    ),
                    label: Text(cat.name),
                    selected: isSelected,
                    selectedColor: cat.color,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                    onSelected: (bool selected) {
                      controller.setCategoryFilter(selected ? cat.id : null);
                    },
                  );
                }),
              ],
            ),
            const SizedBox(height: 16),

            // Priority Filter
            const Text(
              'Priority',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: <Widget>[
                ChoiceChip(
                  label: const Text('All Priorities'),
                  selected: filter.selectedPriority == null,
                  onSelected: (bool selected) {
                    if (selected) controller.setPriorityFilter(null);
                  },
                ),
                ...TaskPriority.values.map((TaskPriority p) {
                  final bool isSelected = filter.selectedPriority == p;
                  return ChoiceChip(
                    avatar: Icon(p.icon, size: 16),
                    label: Text(p.label),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      controller.setPriorityFilter(selected ? p : null);
                    },
                  );
                }),
              ],
            ),

            // Tags Filter
            if (controller.allTags.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              const Text(
                'Tags',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: <Widget>[
                  ChoiceChip(
                    label: const Text('All Tags'),
                    selected: filter.selectedTag == null,
                    onSelected: (bool selected) {
                      if (selected) controller.setSelectedTag(null);
                    },
                  ),
                  ...controller.allTags.map((String tag) {
                    final bool isSelected = filter.selectedTag == tag;
                    return ChoiceChip(
                      label: Text('#$tag'),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        controller.setSelectedTag(selected ? tag : null);
                      },
                    );
                  }),
                ],
              ),
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
