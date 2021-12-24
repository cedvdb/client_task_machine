import 'dart:async';

import 'package:flutter/material.dart';
import 'package:task_machine/task_machine.dart';

class TaskStatusConsumer<O> extends StatefulWidget {
  final Task<dynamic, O> task;
  final Widget Function() readyBuilder;
  final Widget Function() runningBuilder;
  final Widget Function(DataState<O>) completedBuilder;
  final Widget Function(Object e) errorBuilder;

  const TaskStatusConsumer({
    Key? key,
    required this.task,
    required this.readyBuilder,
    required this.runningBuilder,
    required this.completedBuilder,
    required this.errorBuilder,
  }) : super(key: key);

  @override
  State<TaskStatusConsumer<O>> createState() => _TaskStatusConsumerState<O>();
}

class _TaskStatusConsumerState<O> extends State<TaskStatusConsumer<O>> {
  late StreamSubscription _subscription;
  late TaskState<dynamic, O> _taskState = TaskReady();

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
    final error = _taskState.error;

    if (_taskState.status == Status.ready) {
      return widget.readyBuilder();
    }
    if (_taskState.status == Status.running) {
      return widget.runningBuilder();
    }
    if (error != null) {
      return widget.errorBuilder(error);
    }
    if (_taskState.status == Status.completed) {
      return widget.completedBuilder(_taskState.output!);
    }
    throw 'Task status ${_taskState.status} unsupported';
  }
}
