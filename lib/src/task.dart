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

  Task({required I input}) : _state = TaskState.ready(input: input);

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
  Future<void> start() {
    _setState(TaskState.running(input: state.input, isLoading: true));
    return execute();
  }

  /// main execution of the [Task]
  @protected
  Future<void> execute();

  /// restarts the execution of the task with a new [newInput] and by keeping
  /// the same output until another is generated.
  ///
  /// TaskRunning(input: input, loading: true, output: state.output)
  @mustCallSuper
  @protected
  Future<void> restart(I newInput) {
    // not sure this method should stay or if start is enough if output
    _setState(TaskState.running(
        input: newInput, isLoading: true, output: state.output));
    return execute();
  }

  /// completes the task with task state:
  /// set status: Status.completed, output: DataState.loaded(outputData)
  /// throws TaskError if task is already completed
  @mustCallSuper
  @protected
  void complete(O? outputData) {
    if (state.status == Status.completed) {
      throw TaskError('Task already completed');
    }
    _setState(
      TaskState.completed(
          input: state.input, output: DataState.loaded(outputData)),
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
  void onData(O? outputData) {
    _setState(
      TaskState.running(
        input: state.input,
        output: DataState.loaded(outputData),
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
