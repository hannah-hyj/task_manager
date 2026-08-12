import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controllers/task_controller.dart';
import '../models/priority.dart';
import '../models/task_category.dart';

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key, required this.controller});

  final TaskController controller;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, Widget? child) {
        final Map<DateTime, int> history = controller.dailyCompletionsLast7Days;
        final int maxCompletedInADay = history.values.fold(
          1,
          (int prev, int curr) => math.max(prev, curr),
        );

        final int completionPercent = (controller.completionRate * 100).round();

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Productivity Analytics',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Overall Score Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? <Color>[
                              const Color(0xFF064E3B),
                              const Color(0xFF047857),
                            ]
                          : <Color>[
                              const Color(0xFF059669),
                              const Color(0xFF10B981),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'Overall Completion Rate',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$completionPercent%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${controller.completedCount} out of ${controller.totalCount} total tasks finished',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.insights_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 7-Day Completion Velocity Chart Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '7-Day Activity Velocity',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Tasks completed per day',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${controller.completedThisWeekCount} this week',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Bar Chart
                      SizedBox(
                        height: 140,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: history.entries.map((
                            MapEntry<DateTime, int> entry,
                          ) {
                            final DateTime date = entry.key;
                            final int count = entry.value;
                            final double heightFactor = maxCompletedInADay == 0
                                ? 0.0
                                : (count / maxCompletedInADay).clamp(0.08, 1.0);
                            const List<String> weekdays = <String>[
                              'M',
                              'T',
                              'W',
                              'T',
                              'F',
                              'S',
                              'S',
                            ];
                            final bool isToday = date.day == DateTime.now().day;

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  '$count',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: count > 0
                                        ? theme.colorScheme.primary
                                        : Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 28,
                                  height: 80 * heightFactor,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: count > 0
                                          ? <Color>[
                                              theme.colorScheme.primary,
                                              theme.colorScheme.primary
                                                  .withValues(alpha: 0.6),
                                            ]
                                          : <Color>[
                                              isDark
                                                  ? const Color(0xFF334155)
                                                  : const Color(0xFFE2E8F0),
                                              isDark
                                                  ? const Color(0xFF334155)
                                                  : const Color(0xFFE2E8F0),
                                            ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  weekdays[date.weekday - 1],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isToday
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                    color: isToday
                                        ? theme.colorScheme.primary
                                        : (isDark
                                              ? Colors.white60
                                              : const Color(0xFF64748B)),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Category Breakdown Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Category Progress',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (final TaskCategory cat
                          in TaskCategory.defaultCategories) ...<Widget>[
                        _CategoryProgressRow(
                          category: cat,
                          totalTasks: controller.categoryTaskCounts[cat] ?? 0,
                          completionRate:
                              controller.categoryCompletionRates[cat] ?? 0.0,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Priority Distribution
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Pending Tasks by Priority',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: TaskPriority.values.map((TaskPriority p) {
                          final int count =
                              controller.priorityTaskCounts[p] ?? 0;
                          final Color color = p.getColor(isDark);
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 6,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: color.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Column(
                                children: <Widget>[
                                  Icon(p.icon, size: 20, color: color),
                                  const SizedBox(height: 6),
                                  Text(
                                    '$count',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    p.label,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Reset sample data action
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      controller.resetSampleData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sample tasks data reset!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Reset Sample Data'),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategoryProgressRow extends StatelessWidget {
  const _CategoryProgressRow({
    required this.category,
    required this.totalTasks,
    required this.completionRate,
  });

  final TaskCategory category;
  final int totalTasks;
  final double completionRate;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final int percent = (completionRate * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(category.icon, size: 16, color: category.color),
            const SizedBox(width: 8),
            Text(
              category.name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              '$totalTasks tasks • $percent%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white60 : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: totalTasks == 0 ? 0.0 : completionRate,
            minHeight: 6,
            backgroundColor: isDark
                ? const Color(0xFF334155)
                : const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(category.color),
          ),
        ),
      ],
    );
  }
}
