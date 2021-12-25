import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_machine_flutter/src/task_state_stream_consumer.dart';

import 'dummy_task.dart';

void main() {
  late DoNothingTask task;
  late TaskStateStreamConsumer taskDataConsumer;

  setUp(() {
    task = DoNothingTask();
    taskDataConsumer = TaskStateStreamConsumer<String>(
      taskStateStream: task.stateStream,
      processingBuilder: () => Container(
        key: const ValueKey('loading'),
      ),
      outputExistsBuilder: (data, _) => Container(
        key: ValueKey('exists-$data'),
      ),
      outputNotExistsBuilder: (_) => Container(
        key: const ValueKey('not-exists'),
      ),
      errorBuilder: (_) => Container(
        key: const ValueKey('error'),
      ),
    );
  });

  group('TaskDataConsumer', () {
    testWidgets('Should change view when states changes', (tester) async {
      task.start(input: 2);
      await tester.pumpWidget(taskDataConsumer);
      expect(find.byKey(const ValueKey('loading')), findsOneWidget);
      // ignore: invalid_use_of_protected_member
      task.onData('my-data');
      await tester.pump(const Duration(milliseconds: 1));
      expect(find.byKey(const ValueKey('exists-my-data')), findsOneWidget);
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
