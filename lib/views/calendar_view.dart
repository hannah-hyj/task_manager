import 'package:flutter/material.dart';

import '../controllers/task_controller.dart';
import '../models/task.dart';
import '../widgets/add_edit_task_sheet.dart';
import '../widgets/task_card.dart';
import '../widgets/task_details_sheet.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key, required this.controller});

  final TaskController controller;

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  Future<void> _openAddTaskSheet(DateTime date) async {
    final Task? newTask = await showModalBottomSheet<Task>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext ctx) => AddEditTaskSheet(
        initialDate: DateTime(date.year, date.month, date.day, 17, 0),
      ),
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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (BuildContext context, Widget? child) {
        // Filter tasks for the selected date
        final List<Task> dayTasks = widget.controller.allTasks.where((Task t) {
          if (t.dueDate == null) return false;
          return t.dueDate!.year == _selectedDate.year &&
              t.dueDate!.month == _selectedDate.month &&
              t.dueDate!.day == _selectedDate.day;
        }).toList();

        // Calculate days in the current window (e.g. 30 days starting from 7 days ago)
        final DateTime now = DateTime.now();
        final DateTime today = DateTime(now.year, now.month, now.day);
        final List<DateTime> dateRange = List<DateTime>.generate(31, (int i) {
          return today.subtract(const Duration(days: 7)).add(Duration(days: i));
        });

        const List<String> weekdays = <String>[
          'M',
          'T',
          'W',
          'T',
          'F',
          'S',
          'S',
        ];
        const List<String> monthNames = <String>[
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December',
        ];

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${monthNames[_selectedDate.month - 1]} ${_selectedDate.year}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Schedule & Deadlines',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              IconButton(
                tooltip: 'Go to Today',
                icon: const Icon(Icons.today_rounded),
                onPressed: () {
                  setState(() {
                    _selectedDate = today;
                  });
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: <Widget>[
              // Horizontal Date Strip
              Container(
                height: 90,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: dateRange.length,
                  itemBuilder: (BuildContext context, int index) {
                    final DateTime date = dateRange[index];
                    final bool isSelected =
                        date.year == _selectedDate.year &&
                        date.month == _selectedDate.month &&
                        date.day == _selectedDate.day;
                    final bool isToday =
                        date.year == today.year &&
                        date.month == today.month &&
                        date.day == today.day;

                    // Check tasks count on this day
                    final int countOnDay = widget.controller.allTasks
                        .where(
                          (Task t) =>
                              t.dueDate != null &&
                              t.dueDate!.year == date.year &&
                              t.dueDate!.month == date.month &&
                              t.dueDate!.day == date.day,
                        )
                        .length;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedDate = date;
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 54,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : (isDark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : (isToday
                                        ? theme.colorScheme.primary.withValues(
                                            alpha: 0.6,
                                          )
                                        : (isDark
                                              ? const Color(0xFF334155)
                                              : const Color(0xFFE2E8F0))),
                              width: isToday || isSelected ? 1.5 : 1.0,
                            ),
                            boxShadow: isSelected
                                ? <BoxShadow>[
                                    BoxShadow(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                weekdays[date.weekday - 1],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white70
                                      : (isDark
                                            ? Colors.white60
                                            : const Color(0xFF64748B)),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${date.day}',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A)),
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (countOnDay > 0)
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white
                                        : theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              else
                                const SizedBox(height: 5),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Selected Date Summary Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '${dayTasks.length} task${dayTasks.length == 1 ? '' : 's'} scheduled',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF475569),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _openAddTaskSheet(_selectedDate),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Add for date'),
                    ),
                  ],
                ),
              ),

              // Tasks on Date
              Expanded(
                child: dayTasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.event_available_rounded,
                              size: 48,
                              color: isDark
                                  ? Colors.white30
                                  : const Color(0xFFCBD5E1),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No tasks due on this day',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tap "+ Add for date" to schedule something',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.white54
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 90),
                        itemCount: dayTasks.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Task task = dayTasks[index];
                          return TaskCard(
                            task: task,
                            onToggleComplete: () =>
                                widget.controller.toggleTaskCompletion(task.id),
                            onTap: () => _openTaskDetails(task.id),
                            onDelete: () =>
                                widget.controller.deleteTask(task.id),
                            onTogglePin: () =>
                                widget.controller.togglePinTask(task.id),
                            onDuplicate: () =>
                                widget.controller.duplicateTask(task.id),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openAddTaskSheet(_selectedDate),
            child: const Icon(Icons.add_rounded),
          ),
        );
      },
    );
  }
}
