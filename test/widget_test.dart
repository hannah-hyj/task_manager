import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/main.dart';

void main() {
  testWidgets('Task Studio App loads and renders main tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TaskManagementApp());
    await tester.pumpAndSettle();

    // Verify app title
    expect(find.text('Task Studio'), findsWidgets);

    // Verify navigation destinations
    expect(find.byIcon(Icons.task_alt_rounded), findsWidgets);
    expect(find.byIcon(Icons.calendar_month_rounded), findsWidgets);
    expect(find.byIcon(Icons.grid_view_rounded), findsWidgets);
    expect(find.byIcon(Icons.insights_rounded), findsWidgets);

    // Verify Add Task FAB exists
    expect(find.byType(FloatingActionButton), findsWidgets);
  });

  testWidgets('Can navigate across tabs using navigation destinations', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TaskManagementApp());
    await tester.pumpAndSettle();

    // Switch to Calendar tab
    await tester.tap(find.byIcon(Icons.calendar_month_rounded).first);
    await tester.pumpAndSettle();
    expect(find.text('Schedule & Deadlines'), findsOneWidget);

    // Switch to Categories tab
    await tester.tap(find.byIcon(Icons.grid_view_rounded).first);
    await tester.pumpAndSettle();
    expect(find.text('Categories & Projects'), findsOneWidget);

    // Switch to Analytics tab
    await tester.tap(find.byIcon(Icons.insights_rounded).first);
    await tester.pumpAndSettle();
    expect(find.text('Productivity Analytics'), findsOneWidget);

    // Switch back to Tasks tab
    await tester.tap(find.byIcon(Icons.task_alt_rounded).first);
    await tester.pumpAndSettle();
    expect(find.text('Task Studio'), findsWidgets);
  });
}
