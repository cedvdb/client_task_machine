import 'package:equatable/equatable.dart';

import 'data_state.dart';

enum Status { ready, running, completed, closing }

// those properties could, and maybe should be on the task itself, but since
// some properties

class TaskState<I, O> with EquatableMixin {
  final Status status;
  final Object? error;
  final bool isLoading;
  final I? input;
  final DataState<O>? output;

  TaskState.ready()
      : status = Status.ready,
        error = null,
        isLoading = false,
        input = null,
        output = null;

  TaskState.running({
    required this.input,
    required this.isLoading,
    this.error,
    this.output,
  }) : status = Status.running;

  TaskState.completed({
    required this.input,
    required this.output,
    this.error,
  })  : status = Status.completed,
        isLoading = false;

  TaskState.closing({required TaskState<I, O> previousState})
      : status = Status.closing,
        error = previousState.error,
        isLoading = previousState.isLoading,
        input = previousState.input,
        output = null;

  @override
  List<Object?> get props => [status, error, isLoading, input, output];
}
