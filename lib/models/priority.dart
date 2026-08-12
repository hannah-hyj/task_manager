import 'package:flutter/material.dart';

enum TaskPriority {
  urgent(
    label: 'Urgent',
    icon: Icons.priority_high_rounded,
    color: Color(0xFFE53935),
    darkColor: Color(0xFFFF5252),
    level: 4,
  ),
  high(
    label: 'High',
    icon: Icons.keyboard_double_arrow_up_rounded,
    color: Color(0xFFFB8C00),
    darkColor: Color(0xFFFFAB40),
    level: 3,
  ),
  medium(
    label: 'Medium',
    icon: Icons.keyboard_arrow_up_rounded,
    color: Color(0xFF1E88E5),
    darkColor: Color(0xFF448AFF),
    level: 2,
  ),
  low(
    label: 'Low',
    icon: Icons.keyboard_arrow_down_rounded,
    color: Color(0xFF43A047),
    darkColor: Color(0xFF69F0AE),
    level: 1,
  );

  const TaskPriority({
    required this.label,
    required this.icon,
    required this.color,
    required this.darkColor,
    required this.level,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color darkColor;
  final int level;

  Color getColor(bool isDark) => isDark ? darkColor : color;
}
