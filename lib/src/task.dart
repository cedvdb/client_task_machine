import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

abstract class Task<State> {
  final BehaviorSubject<State> _stateController = BehaviorSubject();

  /// emits when the task state changes
  late final Stream<State> stateStream = _stateController.stream;
  late final Stream<void> closesStream = Stream.fromFuture(stateStream.drain());

  late State _state;
  State get state => _state;

  Task(State initialState) {
    setState(initialState);
  }

  /// sets the state of the task to [taskState]
  @protected
  void setState(State taskState) {
    _state = taskState;
    _stateController.add(_state);
  }

  @mustCallSuper
  @protected
  close() {
    _stateController.close();
  }

  @override
  String toString() => '$runtimeType${state.toString()}';
}
