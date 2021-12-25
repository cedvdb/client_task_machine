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
    _setState(TaskReady());
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
  /// state: TaskRunning(input: state.input, isLoading: true)
  @mustCallSuper
  Future<void> start({required I input}) {
    if (state.status == Status.ready) {
      _setState(
        TaskProcessing(input: input, isLoading: true),
      );
      return execute(input);
    }
    return Future.value();
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
    final state = this.state;
    if (state is TaskProcessing<I, O>) {
      _setState(
        TaskCompleted(input: state.input, output: DataState.loaded(data)),
      );
    } else {
      throw TaskError('cannot complete a task which is not running');
    }
  }

  /// Set TaskState as:
  /// sets error: error, status: Status.completed
  @mustCallSuper
  @protected
  void onError(Object error) {
    final state = this.state;
    if (state is TaskProcessing<I, O>) {
      _setState(
        TaskCompleted(error: error, input: state.input, output: state.output),
      );
    } else {
      throw TaskError('cannot add error to a non running task');
    }
  }

  /// Used when a long running task has a stream of incoming data
  /// set output: DataState.loaded(outputData), loading: true
  @mustCallSuper
  @protected
  void onData(O? data) {
    final state = this.state;
    if (state is TaskProcessing<I, O>) {
      _setState(
        TaskProcessing(
          input: state.input,
          output: DataState.loaded(data),
          isLoading: false,
        ),
      );
    } else {
      throw TaskError('cannot add data to a non running task');
    }
  }

  /// closes the task, a closed task will be removed from the task manager
  @mustCallSuper
  @protected
  Future<void> close() async {
    _setState(TaskClosing());
    await _stateController.close();
  }

  @override
  String toString() =>
      '$runtimeType(status: ${state.status} input: ${state.input}, '
      'output: ${state.output}, isLoading: ${state.isLoading}, '
      'hasError: ${state.error != null})';
}
