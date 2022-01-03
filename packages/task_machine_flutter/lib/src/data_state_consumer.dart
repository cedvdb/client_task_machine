import 'dart:async';
import 'package:flutter/material.dart';
import 'package:task_machine/task_machine.dart';

/// Display different builders depending on [ReadState] stream.
class DataStreamConsumer<O> extends StatefulWidget {
  final Widget Function() loading;
  final Widget Function(DataState<O> dataState)? loaded;
  final Widget Function(DataExists<O> dataState)? exists;
  final Widget Function(DataNotExists<O> dataState)? notExists;
  final Widget Function(DataError<O> dataState) errorBuilder;

  final Stream<DataState<O>> dataStream;

  const DataStreamConsumer({
    Key? key,
    required this.dataStream,
    required this.loading,
    required this.errorBuilder,
    this.exists,
    this.notExists,
    this.loaded,
  })  : assert(loaded != null || (exists != null && notExists != null)),
        super(key: key);

  @override
  State<DataStreamConsumer<O>> createState() => _DataStreamConsumerState<O>();
}

class _DataStreamConsumerState<O> extends State<DataStreamConsumer<O>> {
  late StreamSubscription _subscription;
  late DataState<O> _dataState = const DataUnset();
  @override
  void initState() {
    _subscription = widget.dataStream.listen((taskState) {
      setState(() => _dataState = taskState);
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
    final state = _dataState;

    if (state is DataUnset || state is DataLoading) {
      return widget.loading();
    }

    if (state is DataError<O>) {
      return widget.errorBuilder(state);
    }

    if (state is DataLoaded<O>) {
      if (state is DataExists<O> && widget.exists != null) {
        return widget.exists!(state);
      }
      if (state is DataNotExists<O> && widget.notExists != null) {
        return widget.notExists!(state);
      }
      return widget.loaded!(state);
    }

    throw 'State $state not supported';
  }
}
