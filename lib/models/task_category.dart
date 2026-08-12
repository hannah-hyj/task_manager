import 'package:flutter/material.dart';

class TaskCategory {
  const TaskCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.gradientColors,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<Color> gradientColors;

  static const List<TaskCategory> defaultCategories = <TaskCategory>[
    TaskCategory(
      id: 'work',
      name: 'Work',
      icon: Icons.work_rounded,
      color: Color(0xFF6366F1), // Indigo
      gradientColors: <Color>[Color(0xFF6366F1), Color(0xFF818CF8)],
    ),
    TaskCategory(
      id: 'personal',
      name: 'Personal',
      icon: Icons.person_rounded,
      color: Color(0xFFEC4899), // Pink
      gradientColors: <Color>[Color(0xFFEC4899), Color(0xFFF472B6)],
    ),
    TaskCategory(
      id: 'development',
      name: 'Development',
      icon: Icons.code_rounded,
      color: Color(0xFF06B6D4), // Cyan
      gradientColors: <Color>[Color(0xFF06B6D4), Color(0xFF22D3EE)],
    ),
    TaskCategory(
      id: 'design',
      name: 'Design',
      icon: Icons.palette_rounded,
      color: Color(0xFF8B5CF6), // Purple
      gradientColors: <Color>[Color(0xFF8B5CF6), Color(0xFFA78BFA)],
    ),
    TaskCategory(
      id: 'study',
      name: 'Study',
      icon: Icons.menu_book_rounded,
      color: Color(0xFFF59E0B), // Amber
      gradientColors: <Color>[Color(0xFFF59E0B), Color(0xFFFBBF24)],
    ),
    TaskCategory(
      id: 'fitness',
      name: 'Health & Fitness',
      icon: Icons.directions_run_rounded,
      color: Color(0xFF10B981), // Emerald
      gradientColors: <Color>[Color(0xFF10B981), Color(0xFF34D399)],
    ),
    TaskCategory(
      id: 'finance',
      name: 'Finance',
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF14B8A6), // Teal
      gradientColors: <Color>[Color(0xFF14B8A6), Color(0xFF2DD4BF)],
    ),
  ];

  static TaskCategory getById(String id) {
    return defaultCategories.firstWhere(
      (TaskCategory cat) => cat.id == id,
      orElse: () => defaultCategories.first,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskCategory &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
