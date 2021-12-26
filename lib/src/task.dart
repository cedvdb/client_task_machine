import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import 'data_state.dart';
import 'task_state.dart';

class TaskInvalidOperation {
  final String description;
  TaskInvalidOperation(this.description);

  @override
  String toString() => 'TaskInvalidOperation(description: $description)';
}

abstract class Task<I, O> {
  final BehaviorSubject<TaskState<I, O>> _stateController = BehaviorSubject();

  /// emits when the task state changes
  late final Stream<TaskState<I, O>> stateStream = _stateController.stream;

  late TaskState<I, O> _state;
  TaskState<I, O> get state => _state;

  Task() {
    setState(TaskReady());
  }

  /// sets the state of the task to [taskState]
  void setState(TaskState<I, O> taskState) {
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
      setState(TaskRunning(input: input, isLoading: true));
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
    if (state is TaskRunning<I, O>) {
      setState(
        TaskCompleted(input: state.input, output: DataState.loaded(data)),
      );
    } else {
      throw TaskInvalidOperation('cannot complete a task which is not running');
    }
  }

  /// Set TaskState as:
  /// sets error: error, status: Status.error
  @mustCallSuper
  @protected
  void onError(Object error) {
    final state = this.state;
    if (state is TaskRunning<I, O>) {
      setState(
        TaskError(error: error, input: state.input),
      );
    } else {
      throw TaskInvalidOperation('cannot add error to a non running task');
    }
  }

  /// Used when a long running task has a stream of incoming data
  /// set output: DataState.loaded(outputData), loading: true
  @mustCallSuper
  @protected
  void onData(O? data) {
    final state = this.state;
    if (state is TaskRunning<I, O>) {
      setState(
        TaskRunning(
          input: state.input,
          output: DataState.loaded(data),
          isLoading: false,
        ),
      );
    } else {
      throw TaskInvalidOperation('cannot add data to a non running task');
    }
  }

  /// closes the task, a closed task will be removed from the task manager
  @mustCallSuper
  @protected
  Future<void> close() async {
    setState(TaskClosing());
    await _stateController.close();
  }

  @override
  String toString() =>
      '$runtimeType(status: ${state.status} input: ${state.input}, '
      'output: ${state.output}, isLoading: ${state.isLoading}, '
      'hasError: ${state.error != null})';
}
