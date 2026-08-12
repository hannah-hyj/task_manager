import 'package:flutter/material.dart';

import '../models/task.dart';
import 'custom_checkbox.dart';
import 'priority_badge.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleComplete,
    required this.onTap,
    required this.onDelete,
    required this.onTogglePin,
    required this.onDuplicate,
  });

  final Task task;
  final VoidCallback onToggleComplete;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onTogglePin;
  final VoidCallback onDuplicate;

  String _formatDueDate(DateTime due) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime target = DateTime(due.year, due.month, due.day);
    final int diffDays = target.difference(today).inDays;

    if (diffDays == 0) {
      final String hour = due.hour.toString().padLeft(2, '0');
      final String minute = due.minute.toString().padLeft(2, '0');
      return 'Today $hour:$minute';
    } else if (diffDays == 1) {
      return 'Tomorrow';
    } else if (diffDays == -1) {
      return 'Yesterday';
    } else if (diffDays < -1) {
      return '${-diffDays}d overdue';
    } else if (diffDays < 7) {
      const List<String> weekdays = <String>[
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun',
      ];
      return weekdays[due.weekday - 1];
    } else {
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
      return '${months[due.month - 1]} ${due.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color categoryColor = task.category.color;

    return Dismissible(
      key: ValueKey<String>('dismiss_${task.id}'),
      direction: DismissDirection.horizontal,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: <Widget>[
            Icon(
              task.isCompleted
                  ? Icons.replay_rounded
                  : Icons.check_circle_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              task.isCompleted ? 'Mark Incomplete' : 'Mark Complete',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_outline_rounded, color: Colors.white),
          ],
        ),
      ),
      confirmDismiss: (DismissDirection direction) async {
        if (direction == DismissDirection.startToEnd) {
          onToggleComplete();
          return false; // don't remove dismissible item entirely
        } else {
          return true; // remove
        }
      },
      onDismissed: (DismissDirection direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: task.isPinned
                ? categoryColor.withValues(alpha: 0.5)
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: task.isPinned ? 1.5 : 1.0,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Header row: Category pill, Priority badge, Pin indicator, Menu
                  Row(
                    children: <Widget>[
                      // Category Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(
                            alpha: isDark ? 0.2 : 0.1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              task.category.icon,
                              size: 13,
                              color: categoryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.category.name,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: categoryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      PriorityBadge(priority: task.priority),
                      const Spacer(),
                      if (task.isPinned)
                        Tooltip(
                          message: 'Pinned',
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: categoryColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.push_pin_rounded,
                              size: 14,
                              color: categoryColor,
                            ),
                          ),
                        ),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_horiz_rounded,
                          size: 18,
                          color: isDark
                              ? Colors.white54
                              : const Color(0xFF94A3B8),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          maxWidth: 40,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        onSelected: (String action) {
                          switch (action) {
                            case 'pin':
                              onTogglePin();
                            case 'duplicate':
                              onDuplicate();
                            case 'delete':
                              onDelete();
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: 'pin',
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      task.isPinned
                                          ? Icons.push_pin_outlined
                                          : Icons.push_pin_rounded,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      task.isPinned ? 'Unpin' : 'Pin to top',
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'duplicate',
                                child: Row(
                                  children: <Widget>[
                                    Icon(Icons.copy_rounded, size: 18),
                                    SizedBox(width: 10),
                                    Text('Duplicate'),
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(),
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18,
                                      color: Colors.redAccent,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.redAccent),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Main body: Checkbox + Title + Description
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CustomCheckbox(
                        value: task.isCompleted,
                        onChanged: (_) => onToggleComplete(),
                        activeColor: categoryColor,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: task.isCompleted
                                    ? (isDark
                                          ? Colors.white38
                                          : const Color(0xFF94A3B8))
                                    : (isDark
                                          ? const Color(0xFFF8FAFC)
                                          : const Color(0xFF0F172A)),
                                height: 1.3,
                              ),
                            ),
                            if (task.description.trim().isNotEmpty) ...<Widget>[
                              const SizedBox(height: 4),
                              Text(
                                task.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Subtasks mini progress bar
                  if (task.subtasks.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: task.subtasksProgress,
                              minHeight: 4,
                              backgroundColor: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                categoryColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${task.completedSubtasksCount}/${task.subtasks.length}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Footer: Due Date, Estimated Duration, Tags
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      if (task.dueDate != null) ...<Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: task.isOverdue
                                ? const Color(0xFFEF4444)
                                      .withValues(alpha: 0.15)
                                : (task.isDueToday
                                      ? const Color(0xFFF59E0B)
                                            .withValues(alpha: 0.15)
                                      : (isDark
                                            ? const Color(0xFF334155)
                                                  .withValues(alpha: 0.5)
                                            : const Color(0xFFF1F5F9))),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 12,
                                color: task.isOverdue
                                    ? const Color(0xFFEF4444)
                                    : (task.isDueToday
                                          ? const Color(0xFFF59E0B)
                                          : (isDark
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF64748B))),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDueDate(task.dueDate!),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: task.isOverdue
                                      ? const Color(0xFFEF4444)
                                      : (task.isDueToday
                                            ? const Color(0xFFF59E0B)
                                            : (isDark
                                                  ? const Color(0xFF94A3B8)
                                                  : const Color(0xFF64748B))),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (task.estimatedMinutes != null) ...<Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF334155).withValues(alpha: 0.5)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.timer_outlined,
                                size: 12,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${task.estimatedMinutes}m',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      for (final String tag in task.tags)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF334155).withValues(alpha: 0.4)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '#$tag',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
