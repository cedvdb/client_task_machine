import 'package:test/test.dart';
import 'package:task_machine/task_machine.dart';

class DoNothingTask extends Task<int, int> {
  int executionCount = 0;
  DoNothingTask({required int input}) : super(input: input);
  @override
  Future<void> execute(int input) async {
    executionCount++;
  }
}

class AnException implements Exception {}

void main() {
  group('Task', () {
    late DoNothingTask task;

    setUp(() {
      task = DoNothingTask(input: 4);
    });

    test('should have initial state of ready', () async {
      expect(task.state, equals(TaskReady<int, int>(input: 4)));
    });

    test('Should start', () async {
      expect(task.executionCount, equals(0));
      await task.start();
      final expectedState = TaskRunning<int, int>(input: 4, isLoading: true);
      expect(task.stateStream, emitsInOrder([expectedState]));
      expect(task.state, equals(expectedState));
      expect(task.executionCount, equals(1));
    });
    test('Should complete with data exists', () {
      // ignore: invalid_use_of_protected_member
      task.complete(8);
      final expectedState = TaskCompleted<int, int>(
          input: 4, output: DataState<int>.loaded(8), error: null);
      expect(task.stateStream, emitsInOrder([expectedState]));
      expect(task.state, equals(expectedState));
    });

    test('Should complete with data not exists', () {
      // ignore: invalid_use_of_protected_member
      task.complete(null);
      final expectedState = TaskCompleted<int, int>(
          input: 4, output: DataState<int>.loaded(null), error: null);
      expect(task.stateStream, emitsInOrder([expectedState]));
      expect(task.state, equals(expectedState));
    });

    test('Should restart ', () async {
      await task.start();
      // ignore: invalid_use_of_protected_member
      task.complete(4);
      // ignore: invalid_use_of_protected_member
      task.restart(8);
      final expectedState = TaskRunning<int, int>(
        input: 8,
        isLoading: true,
        // previous data still available
        output: const DataExists(4),
      );
      expect(task.stateStream, emitsInOrder([expectedState]));
      expect(task.state, equals(expectedState));
      expect(task.executionCount, equals(2));
    });

    test('Should set error', () async {
      await task.start();
      final e = AnException();
      // ignore: invalid_use_of_protected_member
      task.onError(e);
      final expectedState = TaskCompleted<int, int>(
        input: 4,
        error: e,
        // previous data still available
        output: null,
      );
      expect(task.stateStream, emitsInOrder([expectedState]));
      expect(task.state, equals(expectedState));
    });

    test('Should close', () async {
      await task.start();
      // ignore: invalid_use_of_protected_member
      await task.close();
      expect(task.stateStream.skip(1), emitsDone);
    });
  });
}
