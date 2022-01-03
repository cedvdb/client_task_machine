// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:task_machine_flutter/src/read_state_consumer.dart';

// import 'dummy_task.dart';

// void main() {
//   late DoNothingTask task;
//   late ReadStateConsumer taskDataConsumer;

//   setUp(() {
//     task = DoNothingTask();
//     taskDataConsumer = ReadStateConsumer<String>(
//       readStateStream: task.stateStream,
//       loading: () => Container(
//         key: const ValueKey('loading'),
//       ),
//       completedWithData: (data, _) => Container(
//         key: ValueKey('exists-$data'),
//       ),
//       completedWithoutData: (_) => Container(
//         key: const ValueKey('not-exists'),
//       ),
//       errorBuilder: (_) => Container(
//         key: const ValueKey('error'),
//       ),
//     );
//   });

//   group('TaskDataConsumer', () {
//     testWidgets('Should change view when states changes', (tester) async {
//       task.start(input: 2);
//       await tester.pumpWidget(taskDataConsumer);
//       expect(find.byKey(const ValueKey('loading')), findsOneWidget);
//       // ignore: invalid_use_of_protected_member
//       task.onData('my-data');
//       await tester.pump(const Duration(milliseconds: 1));
//       expect(find.byKey(const ValueKey('exists-my-data')), findsOneWidget);
//       // ignore: invalid_use_of_protected_member
//       task.onData(null);
//       await tester.pump(const Duration(milliseconds: 1));
//       expect(find.byKey(const ValueKey('not-exists')), findsOneWidget);
//       // ignore: invalid_use_of_protected_member
//       task.onError(AnException());
//       await tester.pump(const Duration(milliseconds: 1));
//       expect(find.byKey(const ValueKey('error')), findsOneWidget);
//     });
//   });
// }
