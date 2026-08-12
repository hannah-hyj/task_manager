import 'package:flutter/material.dart';

import '../controllers/task_controller.dart';
import '../controllers/theme_controller.dart';
import '../theme/app_theme.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({
    super.key,
    required this.themeController,
    required this.taskController,
  });

  final ThemeController themeController;
  final TaskController taskController;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: themeController,
      builder: (BuildContext context, Widget? child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      'Settings & Theme',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 12),

                // Theme Mode selector
                const Text(
                  'Appearance',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                SegmentedButton<ThemeMode>(
                  segments: const <ButtonSegment<ThemeMode>>[
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto_rounded, size: 16),
                      label: Text('System'),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_rounded, size: 16),
                      label: Text('Light'),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_rounded, size: 16),
                      label: Text('Dark'),
                    ),
                  ],
                  selected: <ThemeMode>{themeController.themeMode},
                  onSelectionChanged: (Set<ThemeMode> selection) {
                    themeController.setThemeMode(selection.first);
                  },
                ),
                const SizedBox(height: 20),

                // Accent Color Seed selector
                const Text(
                  'Accent Palette',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: AppColorSeed.values.map((AppColorSeed seed) {
                    final bool isSelected = themeController.colorSeed == seed;
                    return InkWell(
                      onTap: () => themeController.setColorSeed(seed),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: seed.color.withValues(
                            alpha: isSelected ? 0.2 : 0.08,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? seed.color : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: seed.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              seed.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Data Management
                const Text(
                  'Data Management',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.cleaning_services_rounded,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  title: const Text(
                    'Clear Completed Tasks',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: Text(
                    'Removes ${taskController.completedCount} completed tasks',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    taskController.clearCompletedTasks();
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Completed tasks cleared!')),
                    );
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.restore_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  title: const Text(
                    'Reset Sample Data',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Restore default demo tasks and categories',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    taskController.resetSampleData();
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sample tasks restored!')),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // About
                Center(
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Task Studio v1.0.0',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white38
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Crafted with Flutter & Material 3',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.white24
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
