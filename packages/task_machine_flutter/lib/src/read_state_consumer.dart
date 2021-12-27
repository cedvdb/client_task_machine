import 'dart:async';
import 'package:flutter/material.dart';
import 'package:task_machine/task_machine.dart';

/// Display different builders depending on [ReadState] stream.
class ReadStateConsumer<O> extends StatefulWidget {
  final Widget Function() loading;
  final Widget Function(O? data, bool isUpdating)? completed;
  final Widget Function(O data, bool isUpdating)? completedWithData;
  final Widget Function(bool isUpdating)? completedWithoutData;
  final Widget Function(Object) errorBuilder;

  final Stream<ReadState<dynamic, O>> readStateStream;

  const ReadStateConsumer({
    Key? key,
    required this.readStateStream,
    required this.loading,
    required this.errorBuilder,
    this.completed,
    this.completedWithData,
    this.completedWithoutData,
  })  : assert(completed != null ||
            (completedWithData != null && completedWithoutData != null)),
        super(key: key);

  @override
  State<ReadStateConsumer<O>> createState() => _ReadStateConsumerState<O>();
}

class _ReadStateConsumerState<O> extends State<ReadStateConsumer<O>> {
  late StreamSubscription _subscription;
  late ReadState<dynamic, O> _readState = const ReadUnstarted();
  @override
  void initState() {
    _subscription = widget.readStateStream.listen((taskState) {
      setState(() => _readState = taskState);
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
    final state = _readState;

    if (state is ReadLoading || state is ReadUnstarted) {
      return widget.loading();
    }

    if (state is ReadError<dynamic, O>) {
      return widget.errorBuilder(state.error);
    }

    if (state is ReadCompleted<dynamic, O>) {
      if (state is ReadCompletedWithData<dynamic, O> &&
          widget.completedWithData != null) {
        return widget.completedWithData!(state.output, state.isUpdating);
      }
      if (state is ReadCompletedWithoutData<dynamic, O> &&
          widget.completedWithoutData != null) {
        return widget.completedWithoutData!(state.isUpdating);
      }
      return widget.completed!(state.output, state.isUpdating);
    }

    throw 'State $state not supported';
  }
}
