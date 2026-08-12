import 'package:flutter/material.dart';

import '../models/task_category.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
    this.taskCount,
  });

  final TaskCategory? category; // null represents "All"
  final bool isSelected;
  final VoidCallback onTap;
  final int? taskCount;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final String label = category?.name ?? 'All';
    final IconData icon = category?.icon ?? Icons.grid_view_rounded;
    final Color categoryColor = category?.color ?? theme.colorScheme.primary;

    final Color backgroundColor = isSelected
        ? categoryColor.withValues(alpha: isDark ? 0.25 : 0.15)
        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9));

    final Color foregroundColor = isSelected
        ? categoryColor
        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B));

    final Color borderColor = isSelected
        ? categoryColor
        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0));

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: borderColor,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon, size: 16, color: foregroundColor),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? (isDark ? Colors.white : const Color(0xFF0F172A))
                        : foregroundColor,
                  ),
                ),
                if (taskCount != null) ...<Widget>[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? categoryColor
                          : (isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$taskCount',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                  ? Colors.white70
                                  : const Color(0xFF475569)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
