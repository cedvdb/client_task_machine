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
}
