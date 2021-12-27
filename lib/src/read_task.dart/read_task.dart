import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:task_machine/src/read_task.dart/read_state.dart';

class TaskInvalidOperation {
  final String description;
  TaskInvalidOperation(this.description);

  @override
  String toString() => 'TaskInvalidOperation(description: $description)';
}

abstract class ReadTask<I, O> {
  final BehaviorSubject<ReadState<I, O>> _stateController = BehaviorSubject();

  /// emits when the task state changes
  late final Stream<ReadState<I, O>> stateStream = _stateController.stream;

  late ReadState<I, O> _state;
  ReadState<I, O> get state => _state;

  ReadTask() {
    _setState(ReadUnstarted<I, O>());
  }

  /// sets the state of the task to [taskState]
  void _setState(ReadState<I, O> taskState) {
    _state = taskState;
    _stateController.add(_state);
  }

  // the methods below this basically call set state with a set of defined
  // states, if the defined state prove to not fit all use cases
  // it might be worth letting the client set the state himself
  // (and remove those predefined behaviors)

  /// starts a task if unstarted
  @mustCallSuper
  Future<void> start({required I input}) {
    if (state is ReadUnstarted<I, O>) {
      _setState(ReadLoading(input: input));
      return execute(input);
    }
    return Future.value();
  }

  /// starts a task even if already started
  @mustCallSuper
  Future<void> restart({required I input}) {
    _setState(ReadLoading(input: input));
    return execute(input);
  }

  /// set the task as updating
  @mustCallSuper
  update(I newInput) {
    final state = this.state;
    if (state is ReadStarted<I, O>) {
      execute(newInput);
    } else {
      throw TaskInvalidOperation(
          'can not update a task which has not been started');
    }
  }

  /// main execution of the [Task]
  @protected
  Future<void> execute(I newInput);

  /// completes the task with read complete state:
  /// throws [TaskInvalidOperation] if task is unstarted
  @mustCallSuper
  @protected
  void complete(O output) {
    final state = this.state;
    if (state is ReadStarted<I, O>) {
      _setState(
        ReadCompleted.build(input: state.input, output: output),
      );
    } else {
      throw TaskInvalidOperation(
          'cannot complete a task which has not been started');
    }
  }

  @mustCallSuper
  @protected
  void onError(Object error) {
    final state = this.state;
    if (state is ReadStarted<I, O>) {
      _setState(
        ReadError(error: error, input: state.input),
      );
    } else {
      throw TaskInvalidOperation(
          'cannot complete a task which has not been started');
    }
  }

  /// closes the task, a closed task won't be able to emit anymore
  @mustCallSuper
  @protected
  Future<void> close() async {
    await _stateController.close();
  }

  @override
  String toString() => state.toString();
}
