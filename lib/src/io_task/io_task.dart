import 'dart:async';

import 'package:meta/meta.dart';
import 'package:task_machine/src/io_task/io_state.dart';
import 'package:task_machine/src/task.dart';
import 'data_state.dart';
import 'package:rxdart/rxdart.dart';

class TaskInvalidOperation {
  final String description;
  TaskInvalidOperation(this.description);

  @override
  String toString() => 'TaskInvalidOperation(description: $description)';
}

abstract class IOTask<I, O> extends Task<IOState<I, O>> {
  late Stream<DataState<O>> outputStream = stateStream.map((s) => s.output);
  late Stream<DataExists<O>> outputExistsStream =
      outputStream.whereType<DataExists<O>>();

  IOTask() : super(const IOState.unstarted());

  // the methods below this basically call set state with a set of defined
  // states, if the defined state prove to not fit all use cases
  // it might be worth letting the client set the state himself
  // (and remove those predefined behaviors)

  /// starts a task if unstarted
  @mustCallSuper
  Future<void> start({required I input}) {
    if (state.isNotStarted || state.input != input) {
      setState(state.copyWith(input: input));
      return execute(input);
    }
    return Future.value();
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
    setState(state.copyWith(output: DataLoaded(output)));
  }

  @mustCallSuper
  @protected
  void onError(Object error) {
    final state = this.state;
    setState(state.copyWith(output: DataError(error)));
  }

  /// closes the task, a closed task won't be able to emit anymore
  @protected
  @override
  Future<void> close() async {
    await super.close();
  }

  @override
  String toString() => state.toString();
}
