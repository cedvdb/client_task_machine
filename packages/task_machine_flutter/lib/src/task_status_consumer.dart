import 'dart:async';

import 'package:flutter/material.dart';
import 'package:task_machine/task_machine.dart';

class TaskStatusConsumer extends StatefulWidget {
  final Task task;
  final Widget Function() readyBuilder;
  final Widget Function() runningBuilder;
  final Widget Function() completedBuilder;
  final Widget Function() errorBuilder;

  const TaskStatusConsumer({
    Key? key,
    required this.task,
    required this.readyBuilder,
    required this.runningBuilder,
    required this.completedBuilder,
    required this.errorBuilder,
  }) : super(key: key);

  @override
  State<TaskStatusConsumer> createState() => _TaskStatusConsumerState();
}

class _TaskStatusConsumerState extends State<TaskStatusConsumer> {
  late StreamSubscription _subscription;
  late TaskState _taskState;

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
    if (_taskState.status == Status.ready) {
      return widget.readyBuilder();
    }
    if (_taskState.status == Status.running) {
      return widget.runningBuilder();
    }
    if (_taskState.status == Status.completed) {
      return widget.completedBuilder();
    }
    throw 'Task status ${_taskState.status} unsupported';
  }
}
