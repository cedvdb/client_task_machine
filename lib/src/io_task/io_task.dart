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
  DataState<O> get output => state.output;
  late Stream<DataState<O>> outputStream = stateStream.map((s) => s.output);
  late Stream<O> outputDataStream = outputStream
      .whereType<DataExists<O>>()
      .map((dataState) => dataState.data);

  IOTask() : super(const IOState.unstarted());
}
