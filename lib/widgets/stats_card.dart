import 'package:flutter/material.dart';

class QuickStatsOverview extends StatelessWidget {
  const QuickStatsOverview({
    super.key,
    required this.totalTasks,
    required this.completedTasks,
    required this.completionRate,
    required this.completedToday,
    required this.overdueCount,
    required this.streakDays,
  });

  final int totalTasks;
  final int completedTasks;
  final double completionRate;
  final int completedToday;
  final int overdueCount;
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final int percent = (completionRate * 100).round();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? <Color>[const Color(0xFF1E1B4B), const Color(0xFF312E81)]
              : <Color>[const Color(0xFF4F46E5), const Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              // Progress ring
              SizedBox(
                width: 58,
                height: 58,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(
                      value: completionRate,
                      strokeWidth: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      percent == 100 && totalTasks > 0
                          ? 'All done! Fantastic work! 🎉'
                          : percent >= 50
                          ? 'Making great progress! 🚀'
                          : 'Let\'s get things done today! ✨',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedTasks of $totalTasks tasks completed',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _StatItem(
                  icon: Icons.check_circle_outline_rounded,
                  value: '$completedToday',
                  label: 'Done Today',
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                _StatItem(
                  icon: Icons.local_fire_department_rounded,
                  value: '$streakDays d',
                  label: 'Streak',
                  iconColor: const Color(0xFFFBBF24),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                _StatItem(
                  icon: Icons.warning_amber_rounded,
                  value: '$overdueCount',
                  label: 'Overdue',
                  iconColor: overdueCount > 0
                      ? const Color(0xFFF87171)
                      : Colors.white70,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 16, color: iconColor ?? Colors.white70),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
