import 'package:flutter/material.dart';

import '../controllers/task_controller.dart';
import '../models/task.dart';
import '../models/task_category.dart';
import '../widgets/add_edit_task_sheet.dart';
import '../widgets/task_card.dart';
import '../widgets/task_details_sheet.dart';

class CategoriesView extends StatelessWidget {
  const CategoriesView({
    super.key,
    required this.controller,
    required this.onSelectCategory,
  });

  final TaskController controller;
  final ValueChanged<String?> onSelectCategory;

  void _showCategoryTasksModal(BuildContext context, TaskCategory category) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext ctx) {
        return ListenableBuilder(
          listenable: controller,
          builder: (BuildContext context, Widget? child) {
            final List<Task> categoryTasks = controller.allTasks
                .where((Task t) => t.categoryId == category.id)
                .toList();

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: category.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(category.icon, color: category.color),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: categoryTasks.isEmpty
                        ? const Center(
                            child: Text('No tasks in this category yet'),
                          )
                        : ListView.builder(
                            itemCount: categoryTasks.length,
                            itemBuilder: (BuildContext context, int index) {
                              final Task task = categoryTasks[index];
                              return TaskCard(
                                task: task,
                                onToggleComplete: () =>
                                    controller.toggleTaskCompletion(task.id),
                                onTap: () {
                                  showModalBottomSheet<void>(
                                    context: context,
                                    isScrollControlled: true,
                                    useSafeArea: true,
                                    builder: (BuildContext c) =>
                                        TaskDetailsSheet(
                                          taskId: task.id,
                                          controller: controller,
                                        ),
                                  );
                                },
                                onDelete: () => controller.deleteTask(task.id),
                                onTogglePin: () =>
                                    controller.togglePinTask(task.id),
                                onDuplicate: () =>
                                    controller.duplicateTask(task.id),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Categories & Projects',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          body: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 260,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: TaskCategory.defaultCategories.length,
            itemBuilder: (BuildContext context, int index) {
              final TaskCategory cat = TaskCategory.defaultCategories[index];
              final int total = controller.categoryTaskCounts[cat] ?? 0;
              final double rate =
                  controller.categoryCompletionRates[cat] ?? 0.0;
              final int percent = (rate * 100).round();

              return Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                  side: BorderSide(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: InkWell(
                  onTap: () => _showCategoryTasksModal(context, cat),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          cat.color.withValues(alpha: isDark ? 0.2 : 0.08),
                          isDark ? const Color(0xFF1E293B) : Colors.white,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: cat.color.withValues(
                                  alpha: isDark ? 0.3 : 0.15,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(cat.icon, color: cat.color, size: 22),
                            ),
                            SizedBox(
                              width: 38,
                              height: 38,
                              child: Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  CircularProgressIndicator(
                                    value: total == 0 ? 0.0 : rate,
                                    strokeWidth: 3.5,
                                    backgroundColor: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFE2E8F0),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      cat.color,
                                    ),
                                  ),
                                  Text(
                                    '$percent%',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? Colors.white70
                                          : const Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              cat.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$total task${total == 1 ? '' : 's'}',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.white60
                                    : const Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final Task? newTask = await showModalBottomSheet<Task>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (BuildContext ctx) => const AddEditTaskSheet(),
              );
              if (newTask != null) {
                controller.addTask(newTask);
              }
            },
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
