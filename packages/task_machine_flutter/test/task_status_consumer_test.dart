import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_machine_flutter/src/task_status_consumer.dart';

import 'dummy_task.dart';

void main() {
  group('TaskStatusConsumer', () {
    late DoNothingTask task;
    late TaskStatusConsumer taskStatusConsumer;

    setUp(() {
      task = DoNothingTask();
      taskStatusConsumer = TaskStatusConsumer(
        task: task,
        readyBuilder: () => Container(key: const ValueKey('ready')),
        runningBuilder: () => Container(key: const ValueKey('running')),
        completedBuilder: (_) => Container(key: const ValueKey('completed')),
        errorBuilder: (e) => Container(key: const ValueKey('error')),
      );
    });

    testWidgets('Should change view when states changes', (tester) async {
      await tester.pumpWidget(taskStatusConsumer);
      expect(find.byKey(const ValueKey('ready')), findsOneWidget);
      // ignore: invalid_use_of_protected_member
      task.start(input: 0);
      await tester.pump(const Duration(milliseconds: 1));
      expect(find.byKey(const ValueKey('running')), findsOneWidget);
      // ignore: invalid_use_of_protected_member
      task.complete(data: '0');
      await tester.pump(const Duration(milliseconds: 1));
      expect(find.byKey(const ValueKey('completed')), findsOneWidget);
    });

    testWidgets('Should display error  changes', (tester) async {
      await tester.pumpWidget(taskStatusConsumer);
      expect(find.byKey(const ValueKey('ready')), findsOneWidget);
      // ignore: invalid_use_of_protected_member
      await task.start(input: 0);
      // ignore: invalid_use_of_protected_member
      task.onError(AnException());
      await tester.pump(const Duration(milliseconds: 1));
      expect(find.byKey(const ValueKey('error')), findsOneWidget);
    });
  });
}
