import 'dart:async';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:task_machine/task_machine.dart';

/// Display different builders depending on the output of a [Task].
///
///  - errorBuilder: if the task has an error
///  - existsBuilder: if a task has data which exists
///  - notExistsBuilder: if a task has data which does not exists (null or empty list)
///  - loadingBuilder: if the task has no data and is loading
///
/// Both [outputExistsBuilder] and [outputNotExistsBuilder] have a [isLoading] parameter.
/// That is because a task can have data and still be loading. For example
/// infinite scroll, chat messages, filters... Typically in those cases
/// the data will still be displayed with sometimes a loading indicator.
class TaskStateStreamConsumer<O> extends StatefulWidget {
  final Widget Function() processingBuilder;
  final Widget Function(O data, bool isLoading) outputExistsBuilder;
  final Widget Function(bool isLoading) outputNotExistsBuilder;
  final Widget Function(Object) errorBuilder;

  final Stream<Read<dynamic, O>> taskStateStream;

  const TaskStateStreamConsumer({
    Key? key,
    required this.taskStateStream,
    required this.processingBuilder,
    required this.outputExistsBuilder,
    required this.outputNotExistsBuilder,
    required this.errorBuilder,
  }) : super(key: key);

  @override
  State<TaskStateStreamConsumer<O>> createState() =>
      _TaskStateStreamConsumerState<O>();
}

class _TaskStateStreamConsumerState<O>
    extends State<TaskStateStreamConsumer<O>> {
  late StreamSubscription _subscription;
  late TaskState<dynamic, O> _taskState = TaskReady();
  @override
  void initState() {
    _subscription = widget.taskStateStream.listen((taskState) {
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
      return widget.outputExistsBuilder(output.data, state.isLoading);
    }
    if (output is DataNotExists<O>) {
      return widget.outputNotExistsBuilder(state.isLoading);
    }

    // this one must be last because it can be true for conditions above too.
    if (state.isLoading || state.status == Status.ready) {
      return widget.processingBuilder();
    }

    throw 'State $state not supported';
  }
}
