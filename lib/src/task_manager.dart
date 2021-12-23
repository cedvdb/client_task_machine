import 'dart:async';

import 'task.dart';

class TaskManagerException implements Exception {
  final String description;
  TaskManagerException(this.description);
}

abstract class TaskManager {
  final Set<Task> _allTasks = {};
  final Map<Type, Set<Task>> _tasksByType = {};
  final Map<Task, StreamSubscription> _subscriptions = {};
  final StreamController<Set<Task>> _stateController = StreamController();
  late final Stream<Set<Task>> state =
      _stateController.stream.asBroadcastStream();

  /// finds a task from the task manager,
  /// throws [TaskManagerException] if multiple tasks of this type are present
  /// was passed
  T find<T>() {
    final foundForType = _tasksByType[T] ?? {};

    if (foundForType.length > 1) {
      throw TaskManagerException(
        'Multiple tasks present for type ${T.runtimeType}'
        ', use getAll() instead',
      );
    }
    return foundForType.first as T;
  }

  /// finds all tasks for a specific type
  Set<T>? findAll<T extends Task>() {
    // we need to cast here because the compiler can't be sure
    // that every task in the set is of that type, only the manager's logic
    // knows that
    return (_tasksByType[T] ?? {}) as Set<T>?;
  }

  /// adds a [task] to the task stack and starts it
  void start(Task task) {
    _addTask(task);
    _listenToTask(task);
    task.start();
  }

  /// adds task to the different data structures
  void _addTask(Task task) {
    final foundForType = _tasksByType[task.runtimeType] ?? {};
    foundForType.add(task);
    _tasksByType[task.runtimeType] = foundForType;
    _allTasks.add(task);
  }

  /// listen to task changes, when the task cannot emit anymore
  /// it is removed
  void _listenToTask(Task task) {
    final sub = task.stateStream.listen(
      (_) => _onTaskChanged(task),
      onDone: () => _removeTask(task),
    );
    _subscriptions[task] = sub;
  }

  /// adds all tasks to the stream
  void _onTaskChanged(Task task) {
    _stateController.add(_allTasks);
  }

  void _removeTask(Task task) {
    _allTasks.remove(task);
    _tasksByType[task.runtimeType]?.remove(task);
    _subscriptions[task]?.cancel();
    _subscriptions.remove(task);
  }
}
