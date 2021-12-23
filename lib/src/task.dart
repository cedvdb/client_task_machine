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
  void setState(TaskState<I, O> taskState) {
    _stateController.add(taskState);
  }

  /// Start the execution of the task with task state:
  /// TaskRunning(input: state.input, loading: true)
  Future<void> start() {
    setState(
      TaskRunning(input: state.input, isLoading: true),
    );
    return execute(state.input);
  }

  /// main execution of the [Task]
  @protected
  Future<void> execute(I input);

  /// restarts the execution of the task with a new [input] and by keeping
  /// the same output until another is generated.
  ///
  /// TaskRunning(input: input, loading: true, output: state.output)
  @protected
  Future<void> restart(I input) {
    // not sure this method should stay or if start is enough if output
    setState(TaskRunning(input: input, isLoading: true, output: state.output));
    return execute(input);
  }

  /// completes the task with task state:
  /// TaskCompleted(input: _state.input, output: DataState.loaded(outputData))
  /// throws TaskError if task is already completed
  @protected
  void complete(O? outputData) {
    if (state.status == Status.completed) {
      throw TaskError('Task already completed');
    }
    setState(
      TaskCompleted(input: state.input, output: DataState.loaded(outputData)),
    );
  }

  /// Set TaskState as:
  /// TaskCompleted(error: error, input: state.input, output: state.output)
  @protected
  void onError(Object error) {
    setState(
      TaskCompleted(error: error, input: state.input, output: state.output),
    );
  }

  /// Used when a long running task has a stream of incoming data
  /// TaskRunning(input: state.input, output: DataState.loaded(outputData), loading: true)
  @protected
  void onData(O outputData) {
    setState(
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
    setState(TaskClosing(input: s, output: output, error: error, isLoading: isLoading))
    await _stateController.close();
  }
}
