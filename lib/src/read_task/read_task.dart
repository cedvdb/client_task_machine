import 'dart:async';

import 'package:meta/meta.dart';
import 'package:task_machine/src/task.dart';
import 'read_state.dart';

class TaskInvalidOperation {
  final String description;
  TaskInvalidOperation(this.description);

  @override
  String toString() => 'TaskInvalidOperation(description: $description)';
}

abstract class ReadTask<I, O> extends Task<ReadState<I, O>> {
  ReadTask() : super(ReadUnstarted<I, O>());

  // the methods below this basically call set state with a set of defined
  // states, if the defined state prove to not fit all use cases
  // it might be worth letting the client set the state himself
  // (and remove those predefined behaviors)

  /// starts a task if unstarted
  @mustCallSuper
  Future<void> start({required I input}) {
    if (state is ReadUnstarted<I, O>) {
      setState(ReadLoading(input: input));
      return execute(input);
    }
    return Future.value();
  }

  /// set the task as updating
  @mustCallSuper
  update(I input) {
    final state = this.state;
    if (state is ReadCompleted<I, O>) {
      setState(
        ReadCompleted.build(
            input: input, output: state.output, isUpdating: true),
      );
    }
    execute(input);
  }

  /// main execution of the [Task]
  @protected
  Future<void> execute(I input);

  /// completes the task with read complete state:
  /// throws [TaskInvalidOperation] if task is unstarted
  @mustCallSuper
  @protected
  void complete(O output) {
    final state = this.state;
    if (state is ReadStarted<I, O>) {
      setState(
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
      setState(
        ReadError(error: error, input: state.input),
      );
    } else {
      throw TaskInvalidOperation(
          'cannot complete a task which has not been started');
    }
  }

  /// closes the task, a closed task won't be able to emit anymore
  @protected
  Future<void> close() async {
    await super.close();
  }

  @override
  String toString() => state.toString();
}
