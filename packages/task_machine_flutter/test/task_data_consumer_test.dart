import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_machine/task_machine.dart';
import 'package:task_machine_flutter/src/task_data_consumer.dart';

typedef Input = int;
typedef Output = int;

class DoNothingTask extends Task<int, int> {
  int executionCount = 0;
  DoNothingTask({required int input}) : super(input: input);
  @override
  Future<void> execute() async {
    executionCount++;
  }
}

class AnException implements Exception {}

void main() {
  late Task task;
  late TaskDataConsumer taskDataConsumer;

  setUp(() {
    task = DoNothingTask(input: 0);
    taskDataConsumer = TaskDataConsumer(
      task: task,
      loadingBuilder: () => Container(
        key: const ValueKey('loading'),
      ),
      existsBuilder: (data, _) => Container(
        key: ValueKey('exists-$data'),
      ),
      notExistsBuilder: (_) => Container(
        key: const ValueKey('not-exists'),
      ),
      errorBuilder: (_) => Container(
        key: const ValueKey('error'),
      ),
    );
  });

  group('TaskDataConsumer', () {
    testWidgets('Should change view when states changes', (tester) async {
      task.start();
      await tester.pumpWidget(taskDataConsumer);
      expect(find.byKey(const ValueKey('loading')), findsOneWidget);
      // ignore: invalid_use_of_protected_member
      task.onData(4);
      await tester.pump(const Duration(milliseconds: 1));
      expect(find.byKey(const ValueKey('exists-4')), findsOneWidget);
      // ignore: invalid_use_of_protected_member
      task.onData(null);
      await tester.pump(const Duration(milliseconds: 1));
      expect(find.byKey(const ValueKey('not-exists')), findsOneWidget);
      // ignore: invalid_use_of_protected_member
      task.onError(AnException());
      await tester.pump(const Duration(milliseconds: 1));
      expect(find.byKey(const ValueKey('error')), findsOneWidget);
    });
  });
}
