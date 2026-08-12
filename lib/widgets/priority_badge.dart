import 'package:flutter/material.dart';

import '../models/priority.dart';

class PriorityBadge extends StatelessWidget {
  const PriorityBadge({
    super.key,
    required this.priority,
    this.compact = false,
  });

  final TaskPriority priority;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color color = priority.getColor(isDark);

    if (compact) {
      return Tooltip(
        message: '${priority.label} Priority',
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(priority.icon, size: 14, color: color),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(priority.icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            priority.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
