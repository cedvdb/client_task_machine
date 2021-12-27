import 'dart:async';
import 'package:flutter/material.dart';
import 'package:task_machine/task_machine.dart';

/// Display different builders depending on [ReadState] stream.
class ReadStateConsumer<I, O> extends StatefulWidget {
  final Widget Function() loading;
  final Widget Function(ReadCompleted<I, O> readState)? completed;
  final Widget Function(ReadCompletedWithData<I, O> readState)?
      completedWithData;
  final Widget Function(ReadCompletedWithoutData<I, O> readState)?
      completedWithoutData;
  final Widget Function(ReadError readState) errorBuilder;

  final Stream<ReadState<I, O>> readStateStream;

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
  State<ReadStateConsumer<I, O>> createState() =>
      _ReadStateConsumerState<I, O>();
}

class _ReadStateConsumerState<I, O> extends State<ReadStateConsumer<I, O>> {
  late StreamSubscription _subscription;
  late ReadState<I, O> _readState = const ReadUnstarted();
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

    if (state is ReadLoading<I, O> || state is ReadUnstarted<I, O>) {
      return widget.loading();
    }

    if (state is ReadError<I, O>) {
      return widget.errorBuilder(state);
    }

    if (state is ReadCompleted<I, O>) {
      if (state is ReadCompletedWithData<I, O> &&
          widget.completedWithData != null) {
        return widget.completedWithData!(state);
      }
      if (state is ReadCompletedWithoutData<I, O> &&
          widget.completedWithoutData != null) {
        return widget.completedWithoutData!(state);
      }
      return widget.completed!(state);
    }

    throw 'State $state not supported';
  }
}
