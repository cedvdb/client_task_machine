import 'package:task_machine/task_machine.dart';
import 'package:test/test.dart';

class DoNothingTask extends Task<int, int> {
  int startCallCount = 0;
  DoNothingTask({required int input}) : super(input: input);

  @override
  Future<void> start() async {
    ++startCallCount;
    super.start();
  }

  @override
  Future<void> execute() async {}
}

void main() {
  late TaskManager taskManager;
  late DoNothingTask task;
  late DoNothingTask anotherTask;

  setUp(() {
    taskManager = TaskManager();
    task = DoNothingTask(input: 0);
    anotherTask = DoNothingTask(input: 2);
  });

  group('Task manager', () {
    test('Should start task', () async {
      expect(taskManager.currentTasks.length, equals(0));
      await taskManager.start(task);
      expect(task.startCallCount, equals(1));
      expect(taskManager.currentTasks.length, equals(1));
    });

    test('Should find task of type', () async {
      await taskManager.start(task);
      final found = taskManager.find<DoNothingTask>();
      expect(found, equals(task));
    });

    test('Should not find if multiple tasks of same type', () async {
      await taskManager.start(task);
      await taskManager.start(anotherTask);
      expect(taskManager.currentTasks.length, equals(2));
      expect(() => taskManager.find<DoNothingTask>(),
          throwsA(isA<TaskManagerException>()));
    });

    test('Should remove task when task is closed', () async {
      await taskManager.start(task);
      await taskManager.start(anotherTask);
      expect(taskManager.currentTasks.length, equals(2));
      // ignore: invalid_use_of_protected_member
      await task.close();
      // waiting for event to propagate
      await Future.delayed(const Duration(milliseconds: 100));
      expect(taskManager.currentTasks.length, equals(1));
      expect(taskManager.currentTasks.first, equals(anotherTask));
    });

    test('Should notify on changes', () async {
      final statusStream = taskManager.tasksStream.map(
        (taskSet) => taskSet.toList().map((task) => task.state.status).toList(),
      );
      expect(
        statusStream,
        emitsInOrder(
          [
            [Status.running],
            [Status.running, Status.running],
            [Status.completed, Status.running],
            [Status.closing, Status.running],
            [Status.running]
          ],
        ),
      );
      await taskManager.start(task);
      await Future.delayed(const Duration(milliseconds: 100));
      await taskManager.start(anotherTask);
      await Future.delayed(const Duration(milliseconds: 100));
      // ignore: invalid_use_of_protected_member
      task.complete(3);
      await Future.delayed(const Duration(milliseconds: 100));
      // ignore: invalid_use_of_protected_member
      task.close();
    });
  });
}
