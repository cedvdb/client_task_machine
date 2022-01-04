import 'dart:async';
import 'package:flutter/material.dart';
import 'package:task_machine/task_machine.dart';

/// Display different builders depending on [ReadState] stream.
class DataStreamConsumer<O> extends StatefulWidget {
  final Widget Function() loading;
  final Widget Function(O? data)? loaded;
  final Widget Function(O data)? exists;
  final Widget Function(O? data)? notExists;
  final Widget Function(Object error) errorBuilder;

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
      return widget.errorBuilder(state.error);
    }

    if (state is DataLoaded<O>) {
      if (state is DataExists<O> && widget.exists != null) {
        return widget.exists!(state.data);
      }
      if (state is DataNotExists<O> && widget.notExists != null) {
        return widget.notExists!(state.data);
      }
      return widget.loaded!(state.data);
    }

    throw 'State $state not supported';
  }
}
