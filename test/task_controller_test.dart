import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/controllers/task_controller.dart';
import 'package:task_manager/models/priority.dart';
import 'package:task_manager/models/subtask.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/models/task_filter.dart';

void main() {
  group('TaskController', () {
    test('initializes with seed tasks', () {
      final TaskController controller = TaskController();
      expect(controller.allTasks.isNotEmpty, isTrue);
      expect(controller.totalCount, equals(controller.allTasks.length));
    });

    test('adds and removes a task', () {
      final TaskController controller = TaskController(initialTasks: <Task>[]);
      final Task task = Task(
        id: 'test_1',
        title: 'New Unit Test Task',
        categoryId: 'work',
        priority: TaskPriority.high,
      );

      controller.addTask(task);
      expect(controller.totalCount, equals(1));
      expect(controller.allTasks.first.title, equals('New Unit Test Task'));

      controller.deleteTask('test_1');
      expect(controller.totalCount, equals(0));
    });

    test('toggles task and subtask completion', () {
      final TaskController controller = TaskController(
        initialTasks: <Task>[
          Task(
            id: 'task_sub',
            title: 'Subtask parent',
            categoryId: 'study',
            subtasks: <SubTask>[
              SubTask(id: 'sub_1', title: 'Sub 1', isCompleted: false),
              SubTask(id: 'sub_2', title: 'Sub 2', isCompleted: false),
            ],
          ),
        ],
      );

      expect(controller.completedCount, equals(0));

      // Toggle first subtask
      controller.toggleSubTaskCompletion('task_sub', 'sub_1');
      expect(controller.allTasks.first.subtasks.first.isCompleted, isTrue);
      expect(controller.allTasks.first.isCompleted, isFalse);

      // Toggle second subtask -> should complete task
      controller.toggleSubTaskCompletion('task_sub', 'sub_2');
      expect(controller.allTasks.first.isCompleted, isTrue);
      expect(controller.completedCount, equals(1));

      // Toggle task directly
      controller.toggleTaskCompletion('task_sub');
      expect(controller.allTasks.first.isCompleted, isFalse);
      expect(
        controller.allTasks.first.subtasks.every((SubTask s) => !s.isCompleted),
        isTrue,
      );
    });

    test('filters tasks by category and status', () {
      final TaskController controller = TaskController(
        initialTasks: <Task>[
          Task(
            id: '1',
            title: 'Work Task',
            categoryId: 'work',
            priority: TaskPriority.urgent,
          ),
          Task(
            id: '2',
            title: 'Personal Task',
            categoryId: 'personal',
            isCompleted: true,
          ),
        ],
      );

      // Category filter
      controller.setCategoryFilter('work');
      expect(controller.filteredTasks.length, equals(1));
      expect(controller.filteredTasks.first.id, equals('1'));

      // Status filter
      controller.setCategoryFilter(null);
      controller.setStatusFilter(TaskStatusFilter.completed);
      expect(controller.filteredTasks.length, equals(1));
      expect(controller.filteredTasks.first.id, equals('2'));
    });

    test('calculates statistics accurately', () {
      final TaskController controller = TaskController(
        initialTasks: <Task>[
          Task(id: '1', title: 'A', categoryId: 'work', isCompleted: true),
          Task(id: '2', title: 'B', categoryId: 'work', isCompleted: true),
          Task(id: '3', title: 'C', categoryId: 'personal', isCompleted: false),
          Task(id: '4', title: 'D', categoryId: 'personal', isCompleted: false),
        ],
      );

      expect(controller.totalCount, equals(4));
      expect(controller.completedCount, equals(2));
      expect(controller.pendingCount, equals(2));
      expect(controller.completionRate, equals(0.5));
    });
  });
}
