import 'dart:async';
import 'package:flutter/material.dart';
import 'package:task_machine/task_machine.dart';

/// Display different builders depending on [ReadState] stream.
class DataStateConsumer<O> extends StatefulWidget {
  final Widget Function() loading;
  final Widget Function(DataState<O> dataState)? loaded;
  final Widget Function(DataExists<O> dataState)? exists;
  final Widget Function(DataNotExists<O> dataState)? notExists;
  final Widget Function(DataError<O> dataState) errorBuilder;

  final Stream<ReadState<I, O>> readStateStream;

  const DataStateConsumer({
    Key? key,
    required this.readStateStream,
    required this.loading,
    required this.errorBuilder,
    this.exists,
    this.exists,
    this.notExists,
  })  : assert(exists != null || (exists != null && notExists != null)),
        super(key: key);

  @override
  State<DataStateConsumer<I, O>> createState() =>
      _DataStateConsumerState<I, O>();
}

class _DataStateConsumerState<I, O> extends State<DataStateConsumer<I, O>> {
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
      if (state is ReadCompletedWithData<I, O> && widget.exists != null) {
        return widget.exists!(state);
      }
      if (state is ReadCompletedWithoutData<I, O> && widget.notExists != null) {
        return widget.notExists!(state);
      }
      return widget.exists!(state);
    }

    throw 'State $state not supported';
  }
}
