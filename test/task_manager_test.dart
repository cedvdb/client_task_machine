import 'package:task_machine/task_machine.dart';
import 'package:test/test.dart';

class DoNothingTask extends Task<int, int> {
  @override
  Future<void> execute(int input) async {}
}

void main() {
  late TaskManager taskManager;
  late DoNothingTask task;
  late DoNothingTask anotherTask;

  setUp(() {
    taskManager = TaskManager();
    task = DoNothingTask();
    anotherTask = DoNothingTask();
  });

  group('Task manager', () {
    test('Should add task', () async {
      expect(taskManager.currentTasks.length, equals(0));
      taskManager.add(task);
      expect(taskManager.currentTasks.length, equals(1));
    });

    test('Should find task of type', () async {
      taskManager.add(task);
      final found = taskManager.find<DoNothingTask>();
      expect(found, equals(task));
    });

    test('Should not find if multiple tasks of same type', () async {
      taskManager.add(task);
      taskManager.add(anotherTask);
      expect(taskManager.currentTasks.length, equals(2));
      expect(() => taskManager.find<DoNothingTask>(),
          throwsA(isA<TaskManagerException>()));
    });

    test('Should remove task when task is closed', () async {
      taskManager.add(task);
      taskManager.add(anotherTask);
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
            [Status.ready],
            [Status.running],
            [Status.running, Status.running],
            [Status.completed, Status.running],
            [Status.closing, Status.running],
            [Status.running]
          ],
        ),
      );
      taskManager.add(task);
      await Future.delayed(const Duration(milliseconds: 100));

      task.start(input: 0);
      await Future.delayed(const Duration(milliseconds: 100));
      taskManager.add(anotherTask..start(input: 9));
      await Future.delayed(const Duration(milliseconds: 100));
      // ignore: invalid_use_of_protected_member
      task.complete(data: 3);
      await Future.delayed(const Duration(milliseconds: 100));
      // ignore: invalid_use_of_protected_member
      task.close();
    });
  });
}
