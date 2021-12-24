import 'dart:async';

import 'task.dart';

class TaskManagerException implements Exception {
  final String description;
  TaskManagerException(this.description);

  @override
  String toString() => 'TaskManagerException(description: $description)';
}

class TaskManager {
  final Set<Task> _allTasks = {};
  Set<Task> get currentTasks => Set.unmodifiable(_allTasks);
  final Map<Type, Set<Task>> _tasksByType = {};
  final Map<Task, StreamSubscription> _subscriptions = {};
  final StreamController<Set<Task>> _tasksController = StreamController();
  late final Stream<Set<Task>> tasksStream =
      _tasksController.stream.asBroadcastStream();

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

  /// adds a [task] to the task stack and starts it
  void add<T>(Task task) {
    _addTask<T>(task);
    _listenToTask(task);
  }

  /// adds task to the different data structures
  void _addTask<T>(Task task) {
    final foundForType = _tasksByType[T] ?? {};
    foundForType.add(task);
    _tasksByType[T] = foundForType;
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
    _tasksController.add(currentTasks);
  }

  void _removeTask(Task task) {
    _allTasks.remove(task);
    _tasksByType[task.runtimeType]?.remove(task);
    _subscriptions[task]?.cancel();
    _subscriptions.remove(task);
    _onTaskChanged(task);
  }
}
