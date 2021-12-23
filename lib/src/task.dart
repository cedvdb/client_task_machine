import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:meta/meta.dart';
import 'data_state.dart';
import 'task_state.dart';

class TaskError {
  final String description;
  TaskError(this.description);
}

abstract class Task<I, O> {
  final BehaviorSubject<TaskState<I, O>> _stateController = BehaviorSubject();

  /// emits when the task state changes
  late final Stream<TaskState<I, O>> stateStream = _stateController.stream;

  TaskState<I, O> get state => _stateController.value;

  Task({required I input}) {
    _stateController.add(TaskReady(input: input));
  }

  /// sets the state of the task to [taskState]
  @protected
  void _setState(TaskState<I, O> taskState) {
    _stateController.add(taskState);
  }

  /// Start the execution of the task with task state:
  /// sets loading: true
  Future<void> start() {
    _setState(
      TaskRunning(input: state.input, isLoading: true),
    );
    return execute(state.input);
  }

  /// main execution of the [Task]
  @protected
  Future<void> execute(I input);

  /// restarts the execution of the task with a new [newInput] and by keeping
  /// the same output until another is generated.
  ///
  /// TaskRunning(input: input, loading: true, output: state.output)
  @protected
  Future<void> restart(I newInput) {
    // not sure this method should stay or if start is enough if output
    _setState(
        TaskRunning(input: newInput, isLoading: true, output: state.output));
    return execute(newInput);
  }

  /// completes the task with task state:
  /// set status: Status.completed, output: DataState.loaded(outputData)
  /// throws TaskError if task is already completed
  @protected
  void complete(O? outputData) {
    if (state.status == Status.completed) {
      throw TaskError('Task already completed');
    }
    _setState(
      TaskCompleted(input: state.input, output: DataState.loaded(outputData)),
    );
  }

  /// Set TaskState as:
  /// sets error: error, status: Status.completed
  @protected
  void onError(Object error) {
    _setState(
      TaskCompleted(error: error, input: state.input, output: state.output),
    );
  }

  /// Used when a long running task has a stream of incoming data
  /// set output: DataState.loaded(outputData), loading: true
  @protected
  void onData(O outputData) {
    _setState(
      TaskRunning(
        input: state.input,
        output: DataState.loaded(outputData),
        isLoading: false,
      ),
    );
  }

  /// closes the task, a closed task will be removed from the task manager
  @protected
  Future<void> close() async {
    _setState(TaskClosing(state));
    await _stateController.close();
  }
}
