import 'dart:async';

import 'package:flutter/material.dart';
import 'package:task_machine/task_machine.dart';

/// Display different builders depending on the output of a [Task].
///
///  - errorBuilder: if the task has an error
///  - existsBuilder: if a task has data which exists
///  - notExistsBuilder: if a task has data which does not exists (null or empty list)
///  - loadingBuilder: if the task has no data and is loading
///
/// Both [existsBuilder] and [notExistsBuilder] have a [isLoading] parameter.
/// That is because a task can have data and still be loading. For example
/// infinite scroll, chat messages, filters... Typically in those cases
/// the data will still be displayed with sometimes a loading indicator.
class TaskDataConsumer<O> extends StatefulWidget {
  final Widget Function() loadingBuilder;
  final Widget Function(O data, bool isLoading) existsBuilder;
  final Widget Function(bool isLoading) notExistsBuilder;
  final Widget Function(Object) errorBuilder;

  final Task<dynamic, O> task;

  const TaskDataConsumer({
    Key? key,
    required this.task,
    required this.loadingBuilder,
    required this.existsBuilder,
    required this.notExistsBuilder,
    required this.errorBuilder,
  }) : super(key: key);

  @override
  State<TaskDataConsumer<O>> createState() => _TaskDataConsumerState<O>();
}

class _TaskDataConsumerState<O> extends State<TaskDataConsumer<O>> {
  late StreamSubscription _subscription;
  late TaskState<dynamic, O> _taskState = TaskState.ready(input: null);
  @override
  void initState() {
    _subscription = widget.task.stateStream.listen((taskState) {
      setState(() => _taskState = taskState);
    });
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _taskState;
    final output = state.output;
    final error = state.error;

    if (error != null) {
      return widget.errorBuilder(error);
    }
    if (output is DataExists<O>) {
      return widget.existsBuilder(output.data, state.isLoading);
    }
    if (output is DataNotExists<O>) {
      return widget.notExistsBuilder(state.isLoading);
    }

    // this one must be last because it can be true for conditions above too.
    if (state.isLoading || state.status == Status.ready) {
      return widget.loadingBuilder();
    }

    throw 'State $state not supported';
  }
}
