import 'package:flutter/material.dart';

import '../models/priority.dart';
import '../models/subtask.dart';
import '../models/task.dart';
import '../models/task_category.dart';

class AddEditTaskSheet extends StatefulWidget {
  const AddEditTaskSheet({
    super.key,
    this.initialTask,
    this.initialDate,
    this.initialCategoryId,
  });

  final Task? initialTask;
  final DateTime? initialDate;
  final String? initialCategoryId;

  @override
  State<AddEditTaskSheet> createState() => _AddEditTaskSheetState();
}

class _AddEditTaskSheetState extends State<AddEditTaskSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _subtaskInputController;
  late TextEditingController _tagInputController;

  late String _selectedCategoryId;
  late TaskPriority _selectedPriority;
  DateTime? _dueDate;
  int? _estimatedMinutes;
  late List<SubTask> _subtasks;
  late List<String> _tags;
  bool _isPinned = false;

  @override
  void initState() {
    super.initState();
    final Task? t = widget.initialTask;
    _titleController = TextEditingController(text: t?.title ?? '');
    _descController = TextEditingController(text: t?.description ?? '');
    _subtaskInputController = TextEditingController();
    _tagInputController = TextEditingController();

    _selectedCategoryId =
        t?.categoryId ??
        widget.initialCategoryId ??
        TaskCategory.defaultCategories.first.id;
    _selectedPriority = t?.priority ?? TaskPriority.medium;
    _dueDate = t?.dueDate ?? widget.initialDate;
    _estimatedMinutes = t?.estimatedMinutes;
    _subtasks = t != null ? List<SubTask>.from(t.subtasks) : <SubTask>[];
    _tags = t != null ? List<String>.from(t.tags) : <String>[];
    _isPinned = t?.isPinned ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _subtaskInputController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  void _addSubtask() {
    final String text = _subtaskInputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _subtasks.add(
          SubTask(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: text,
          ),
        );
        _subtaskInputController.clear();
      });
    }
  }

  void _addTag() {
    final String text = _tagInputController.text.trim().replaceAll('#', '');
    if (text.isNotEmpty && !_tags.contains(text)) {
      setState(() {
        _tags.add(text);
        _tagInputController.clear();
      });
    }
  }

  Future<void> _pickDueDate() async {
    final DateTime initial = _dueDate ?? DateTime.now();
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );

    if (date != null && mounted) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: _dueDate != null
            ? TimeOfDay.fromDateTime(_dueDate!)
            : const TimeOfDay(hour: 17, minute: 0),
      );

      if (mounted) {
        setState(() {
          if (time != null) {
            _dueDate = DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            );
          } else {
            _dueDate = DateTime(date.year, date.month, date.day, 23, 59);
          }
        });
      }
    }
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final bool isEditing = widget.initialTask != null;
    final Task task = Task(
      id: isEditing
          ? widget.initialTask!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      categoryId: _selectedCategoryId,
      priority: _selectedPriority,
      dueDate: _dueDate,
      isCompleted: isEditing ? widget.initialTask!.isCompleted : false,
      completedAt: isEditing ? widget.initialTask!.completedAt : null,
      createdAt: isEditing ? widget.initialTask!.createdAt : DateTime.now(),
      subtasks: _subtasks,
      tags: _tags,
      estimatedMinutes: _estimatedMinutes,
      isPinned: _isPinned,
    );

    Navigator.of(context).pop(task);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final bool isEditing = widget.initialTask != null;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 8,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    isEditing ? 'Edit Task' : 'New Task',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      IconButton(
                        tooltip: _isPinned ? 'Pinned' : 'Pin to top',
                        icon: Icon(
                          _isPinned
                              ? Icons.push_pin_rounded
                              : Icons.push_pin_outlined,
                          color: _isPinned
                              ? theme.colorScheme.primary
                              : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPinned = !_isPinned;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title Field
              TextFormField(
                controller: _titleController,
                autofocus: !isEditing,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  labelText: 'Task Title *',
                  hintText: 'What needs to be done?',
                  prefixIcon: Icon(Icons.check_circle_outline_rounded),
                ),
                validator: (String? val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Description Field
              TextFormField(
                controller: _descController,
                maxLines: 3,
                minLines: 2,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Add context, links, or notes...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: Icon(Icons.notes_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Category Selector
              const Text(
                'Category',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: TaskCategory.defaultCategories.map((
                    TaskCategory cat,
                  ) {
                    final bool isSelected = cat.id == _selectedCategoryId;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        selected: isSelected,
                        avatar: Icon(
                          cat.icon,
                          size: 16,
                          color: isSelected ? Colors.white : cat.color,
                        ),
                        label: Text(cat.name),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 13,
                        ),
                        selectedColor: cat.color,
                        backgroundColor: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF1F5F9),
                        onSelected: (bool selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategoryId = cat.id;
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 18),

              // Priority Selector
              const Text(
                'Priority',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              SegmentedButton<TaskPriority>(
                segments: TaskPriority.values.map((TaskPriority p) {
                  return ButtonSegment<TaskPriority>(
                    value: p,
                    icon: Icon(p.icon, size: 16),
                    label: Text(p.label, style: const TextStyle(fontSize: 12)),
                  );
                }).toList(),
                selected: <TaskPriority>{_selectedPriority},
                onSelectionChanged: (Set<TaskPriority> set) {
                  setState(() {
                    _selectedPriority = set.first;
                  });
                },
              ),
              const SizedBox(height: 18),

              // Due Date & Estimated Time Row
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _pickDueDate,
                      icon: Icon(
                        Icons.calendar_month_rounded,
                        size: 18,
                        color: _dueDate != null
                            ? theme.colorScheme.primary
                            : Colors.grey,
                      ),
                      label: Text(
                        _dueDate != null
                            ? '${_dueDate!.month}/${_dueDate!.day} ${_dueDate!.hour.toString().padLeft(2, '0')}:${_dueDate!.minute.toString().padLeft(2, '0')}'
                            : 'Set Due Date',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: _dueDate != null
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: _dueDate != null
                              ? (isDark ? Colors.white : Colors.black87)
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  if (_dueDate != null) ...<Widget>[
                    IconButton(
                      tooltip: 'Clear Date',
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () => setState(() => _dueDate = null),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),

              // Duration chips
              Row(
                children: <Widget>[
                  const Text(
                    'Estimate:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  for (final int mins in <int>[15, 30, 45, 60, 90]) ...<Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: FilterChip(
                        label: Text('${mins}m'),
                        selected: _estimatedMinutes == mins,
                        onSelected: (bool selected) {
                          setState(() {
                            _estimatedMinutes = selected ? mins : null;
                          });
                        },
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 18),

              // Subtasks Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Subtasks (${_subtasks.length})',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_subtasks.isNotEmpty)
                Column(
                  children: _subtasks.asMap().entries.map((
                    MapEntry<int, SubTask> entry,
                  ) {
                    final int idx = entry.key;
                    final SubTask sub = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
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
                              onChanged: (bool? val) {
                                setState(() {
                                  _subtasks[idx] = sub.copyWith(
                                    isCompleted: val ?? false,
                                  );
                                });
                              },
                            ),
                            Expanded(
                              child: Text(
                                sub.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  decoration: sub.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 16),
                              onPressed: () {
                                setState(() {
                                  _subtasks.removeAt(idx);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _subtaskInputController,
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Add a subtask...',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => _addSubtask(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.add_rounded),
                    onPressed: _addSubtask,
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Tags Section
              const Text(
                'Tags',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (_tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _tags.map((String tag) {
                      return Chip(
                        label: Text('#$tag'),
                        onDeleted: () {
                          setState(() {
                            _tags.remove(tag);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _tagInputController,
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Add tag (e.g. UX, urgent, sprint3)',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => _addTag(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.add_rounded),
                    onPressed: _addTag,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Save Action Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _saveTask,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.check_rounded),
                  label: Text(
                    isEditing ? 'Save Changes' : 'Create Task',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
