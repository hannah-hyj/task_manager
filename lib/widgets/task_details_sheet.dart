import 'package:flutter/material.dart';

import '../controllers/task_controller.dart';
import '../models/subtask.dart';
import '../models/task.dart';
import 'add_edit_task_sheet.dart';
import 'custom_checkbox.dart';
import 'priority_badge.dart';

class TaskDetailsSheet extends StatefulWidget {
  const TaskDetailsSheet({
    super.key,
    required this.taskId,
    required this.controller,
  });

  final String taskId;
  final TaskController controller;

  @override
  State<TaskDetailsSheet> createState() => _TaskDetailsSheetState();
}

class _TaskDetailsSheetState extends State<TaskDetailsSheet> {
  final TextEditingController _subtaskInputController = TextEditingController();

  @override
  void dispose() {
    _subtaskInputController.dispose();
    super.dispose();
  }

  void _handleAddSubtask(String taskId) {
    final String text = _subtaskInputController.text.trim();
    if (text.isNotEmpty) {
      widget.controller.addSubTask(taskId, text);
      _subtaskInputController.clear();
    }
  }

  Future<void> _openEditSheet(Task task) async {
    final Task? updated = await showModalBottomSheet<Task>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext ctx) => AddEditTaskSheet(initialTask: task),
    );

    if (updated != null) {
      widget.controller.updateTask(updated);
    }
  }

  String _formatDateTime(DateTime dt) {
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final String hour = dt.hour.toString().padLeft(2, '0');
    final String min = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at $hour:$min';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (BuildContext context, Widget? child) {
        final Task? task = widget.controller.allTasks
            .where((Task t) => t.id == widget.taskId)
            .firstOrNull;

        if (task == null) {
          return const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: Text('Task not found')),
          );
        }

        final Color categoryColor = task.category.color;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 24,
            right: 24,
            top: 12,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Top Category & Priority & Close row
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(
                          alpha: isDark ? 0.25 : 0.12,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            task.category.icon,
                            size: 14,
                            color: categoryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            task.category.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: categoryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    PriorityBadge(priority: task.priority),
                    const Spacer(),
                    IconButton(
                      tooltip: task.isPinned ? 'Pinned' : 'Pin to top',
                      icon: Icon(
                        task.isPinned
                            ? Icons.push_pin_rounded
                            : Icons.push_pin_outlined,
                        color: task.isPinned ? categoryColor : Colors.grey,
                      ),
                      onPressed: () => widget.controller.togglePinTask(task.id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Title and Main Checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CustomCheckbox(
                      size: 28,
                      value: task.isCompleted,
                      activeColor: categoryColor,
                      onChanged: (_) =>
                          widget.controller.toggleTaskCompletion(task.id),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isCompleted
                              ? (isDark
                                    ? Colors.white38
                                    : const Color(0xFF94A3B8))
                              : (isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A)),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),

                // Description
                if (task.description.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      task.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],

                // Metadata cards (Due Date, Estimate, Status)
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    if (task.dueDate != null)
                      _MetaTile(
                        icon: Icons.calendar_today_rounded,
                        title: 'Due Date',
                        subtitle: _formatDateTime(task.dueDate!),
                        isWarning: task.isOverdue,
                      ),
                    if (task.estimatedMinutes != null)
                      _MetaTile(
                        icon: Icons.timer_outlined,
                        title: 'Estimate',
                        subtitle: '${task.estimatedMinutes} minutes',
                      ),
                    _MetaTile(
                      icon: task.isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.pending_actions_rounded,
                      title: 'Status',
                      subtitle: task.isCompleted ? 'Completed' : 'In Progress',
                      accentColor: task.isCompleted
                          ? const Color(0xFF10B981)
                          : const Color(0xFF6366F1),
                    ),
                  ],
                ),

                // Subtasks interactive list
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Subtasks (${task.completedSubtasksCount}/${task.subtasks.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (task.subtasks.isNotEmpty)
                      Text(
                        '${(task.subtasksProgress * 100).round()}% done',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: categoryColor,
                        ),
                      ),
                  ],
                ),
                if (task.subtasks.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: task.subtasksProgress,
                      minHeight: 6,
                      backgroundColor: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final SubTask sub in task.subtasks)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Checkbox(
                              value: sub.isCompleted,
                              activeColor: categoryColor,
                              onChanged: (_) => widget.controller
                                  .toggleSubTaskCompletion(task.id, sub.id),
                            ),
                            Expanded(
                              child: Text(
                                sub.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  decoration: sub.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: sub.isCompleted
                                      ? (isDark
                                            ? Colors.white38
                                            : const Color(0xFF94A3B8))
                                      : (isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A)),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 16,
                              ),
                              onPressed: () => widget.controller.removeSubTask(
                                task.id,
                                sub.id,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],

                // Inline add subtask
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _subtaskInputController,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Add subtask...',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                        onSubmitted: (_) => _handleAddSubtask(task.id),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.add_rounded),
                      onPressed: () => _handleAddSubtask(task.id),
                    ),
                  ],
                ),

                // Tags
                if (task.tags.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 20),
                  const Text(
                    'Tags',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: task.tags.map((String t) {
                      return Chip(
                        label: Text('#$t'),
                        labelStyle: const TextStyle(fontSize: 12),
                      );
                    }).toList(),
                  ),
                ],

                // Timestamps info
                const SizedBox(height: 20),
                Text(
                  'Created: ${_formatDateTime(task.createdAt)}'
                  '${task.completedAt != null ? '\nCompleted: ${_formatDateTime(task.completedAt!)}' : ''}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                    height: 1.5,
                  ),
                ),

                // Action buttons: Edit, Duplicate, Delete
                const SizedBox(height: 28),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => _openEditSheet(task),
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        label: const Text(
                          'Edit',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          widget.controller.duplicateTask(task.id);
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: const Text(
                          'Duplicate',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444)
                            .withValues(alpha: 0.15),
                        foregroundColor: const Color(0xFFEF4444),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(14),
                      ),
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () {
                        widget.controller.deleteTask(task.id);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MetaTile extends StatelessWidget {
  const _MetaTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isWarning = false,
    this.accentColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isWarning;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color color = isWarning
        ? const Color(0xFFEF4444)
        : (accentColor ?? (isDark ? Colors.white70 : const Color(0xFF475569)));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isWarning
            ? const Color(0xFFEF4444).withValues(alpha: 0.1)
            : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWarning
              ? const Color(0xFFEF4444).withValues(alpha: 0.3)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
