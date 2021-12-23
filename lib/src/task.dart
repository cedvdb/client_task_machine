import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import 'data_state.dart';
import 'task_state.dart';

class TaskError {
  final String description;
  TaskError(this.description);

  @override
  String toString() => 'TaskError(description: $description)';
}

abstract class Task<I, O> {
  final BehaviorSubject<TaskState<I, O>> _stateController = BehaviorSubject();

  /// emits when the task state changes
  late final Stream<TaskState<I, O>> stateStream = _stateController.stream;

  late TaskState<I, O> _state;
  TaskState<I, O> get state => _state;

  Task() {
    _setState(TaskState.ready());
  }

  /// sets the state of the task to [taskState]
  void _setState(TaskState<I, O> taskState) {
    _state = taskState;
    _stateController.add(_state);
  }

  // the methods below this basically call set state with a set of defined
  // states, if the defined state prove to not fit all use cases
  // it might be worth letting the client set the state himself
  // (and remove those predefined behaviors)

  /// Start the execution of the task with task state:
  /// state: TaskRunning(input: state.input, isLoading: true, output: state.output)
  ///
  /// note that start can be called multiple times during the lifetime of
  /// a task. In which case the old output will still be there until a new one
  /// replaces it (with complete(newData), or onData(newData))
  @mustCallSuper
  Future<void> start({required I input}) {
    _setState(
      TaskState.running(input: input, isLoading: true, output: state.output),
    );
    return execute(input);
  }

  /// main execution of the [Task]
  @protected
  Future<void> execute(I input);

  /// completes the task with task state:
  /// set status: Status.completed, output: DataState.loaded(outputData)
  /// throws TaskError if task is already completed
  @mustCallSuper
  @protected
  void complete({required O? data}) {
    if (state.status == Status.completed) {
      throw TaskError('Task already completed');
    }
    _setState(
      TaskState.completed(input: state.input, output: DataState.loaded(data)),
    );
  }

  /// Set TaskState as:
  /// sets error: error, status: Status.completed
  @mustCallSuper
  @protected
  void onError(Object error) {
    _setState(
      TaskState.completed(
          error: error, input: state.input, output: state.output),
    );
  }

  /// Used when a long running task has a stream of incoming data
  /// set output: DataState.loaded(outputData), loading: true
  @mustCallSuper
  @protected
  void onData(O? data) {
    _setState(
      TaskState.running(
        input: state.input,
        output: DataState.loaded(data),
        isLoading: false,
      ),
    );
  }

  /// closes the task, a closed task will be removed from the task manager
  @mustCallSuper
  @protected
  Future<void> close() async {
    _setState(TaskState.closing(previousState: state));
    await _stateController.close();
  }

  @override
  String toString() =>
      '$runtimeType(status: ${state.status} input: ${state.input}, '
      'output: ${state.output}, isLoading: ${state.isLoading}, '
      'hasError: ${state.error != null})';
}
