import 'package:flutter/material.dart';

import 'controllers/task_controller.dart';
import 'controllers/theme_controller.dart';
import 'theme/app_theme.dart';
import 'views/analytics_view.dart';
import 'views/calendar_view.dart';
import 'views/categories_view.dart';
import 'views/tasks_view.dart';
import 'widgets/settings_sheet.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TaskManagementApp());
}

class TaskManagementApp extends StatefulWidget {
  const TaskManagementApp({super.key});

  @override
  State<TaskManagementApp> createState() => _TaskManagementAppState();
}

class _TaskManagementAppState extends State<TaskManagementApp> {
  final ThemeController _themeController = ThemeController();
  final TaskController _taskController = TaskController();

  @override
  void dispose() {
    _themeController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          title: 'Task Studio',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(_themeController.colorSeed.color),
          darkTheme: AppTheme.dark(_themeController.colorSeed.color),
          themeMode: _themeController.themeMode,
          home: MainScreen(
            themeController: _themeController,
            taskController: _taskController,
          ),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
    required this.themeController,
    required this.taskController,
  });

  final ThemeController themeController;
  final TaskController taskController;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _openSettings() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext ctx) => SettingsSheet(
        themeController: widget.themeController,
        taskController: widget.taskController,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> views = <Widget>[
      TasksView(controller: widget.taskController),
      CalendarView(controller: widget.taskController),
      CategoriesView(
        controller: widget.taskController,
        onSelectCategory: (String? categoryId) {
          widget.taskController.setCategoryFilter(categoryId);
          setState(() {
            _currentIndex = 0;
          });
        },
      ),
      AnalyticsView(controller: widget.taskController),
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isWide = constraints.maxWidth >= 720;

        if (isWide) {
          return Scaffold(
            body: Row(
              children: <Widget>[
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  extended: constraints.maxWidth >= 960,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        if (constraints.maxWidth >= 960) ...<Widget>[
                          const SizedBox(width: 12),
                          const Text(
                            'Task Studio',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: IconButton(
                          tooltip: 'Settings',
                          icon: const Icon(Icons.settings_rounded),
                          onPressed: _openSettings,
                        ),
                      ),
                    ),
                  ),
                  destinations: const <NavigationRailDestination>[
                    NavigationRailDestination(
                      icon: Icon(Icons.task_alt_rounded),
                      label: Text('Tasks'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.calendar_month_rounded),
                      label: Text('Calendar'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.grid_view_rounded),
                      label: Text('Categories'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.insights_rounded),
                      label: Text('Analytics'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: views[_currentIndex]),
              ],
            ),
          );
        }

        return Scaffold(
          body: views[_currentIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (int index) {
              if (index == 4) {
                _openSettings();
              } else {
                setState(() {
                  _currentIndex = index;
                });
              }
            },
            destinations: const <NavigationDestination>[
              NavigationDestination(
                icon: Icon(Icons.task_alt_rounded),
                label: 'Tasks',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_rounded),
                label: 'Calendar',
              ),
              NavigationDestination(
                icon: Icon(Icons.grid_view_rounded),
                label: 'Categories',
              ),
              NavigationDestination(
                icon: Icon(Icons.insights_rounded),
                label: 'Analytics',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}
