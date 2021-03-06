import 'package:equatable/equatable.dart';

import 'data_state.dart';

enum Status { ready, running, completed, error, closing }

// those properties could, and maybe should be on the task itself, but since
// some properties

abstract class TaskState<I, O> with EquatableMixin {
  Status get status;
  Object? get error;
  bool get isLoading;
  I? get input;
  DataState<O>? get output;

  @override
  List<Object?> get props => [status, error, isLoading, input, output];
}

class TaskReady<I, O> extends TaskState<I, O> {
  @override
  final Object? error = null;

  @override
  final I? input = null;

  @override
  final DataState<O>? output = null;

  @override
  final bool isLoading = false;

  @override
  final Status status = Status.ready;
}

class TaskRunning<I, O> extends TaskState<I, O> {
  @override
  final Object? error = null;

  @override
  final I input;

  @override
  final DataState<O>? output;

  @override
  final bool isLoading;

  @override
  final Status status = Status.running;

  TaskRunning({
    this.output,
    required this.input,
    required this.isLoading,
  });
}

class TaskCompleted<I, O> extends TaskState<I, O> {
  @override
  final Object? error = null;

  @override
  final I input;

  @override
  final DataState<O> output;

  @override
  final bool isLoading = false;

  @override
  final Status status = Status.completed;

  TaskCompleted({
    required this.input,
    required this.output,
  });
}

class TaskError<I, O> extends TaskState<I, O> {
  @override
  final Object error;

  @override
  final I input;

  @override
  final DataState<O>? output = null;

  @override
  final bool isLoading = false;

  @override
  final Status status = Status.error;

  TaskError({
    required this.input,
    required this.error,
  });
}

class TaskClosing<I, O> extends TaskState<I, O> {
  @override
  final Object? error = null;

  @override
  final I? input = null;

  @override
  final DataState<O>? output = null;

  @override
  final bool isLoading = false;

  @override
  final Status status = Status.closing;
}
