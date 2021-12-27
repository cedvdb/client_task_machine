import 'dart:async';

import 'package:rxdart/rxdart.dart';

abstract class Task<State> {
  final BehaviorSubject<State> _stateController = BehaviorSubject();

  /// emits when the task state changes
  late final Stream<State> stateStream = _stateController.stream;

  late State _state;
  State get state => _state;

  Task(State initialState) {
    setState(initialState);
  }

  /// sets the state of the task to [taskState]
  void setState(State taskState) {
    _state = taskState;
    _stateController.add(_state);
  }
}
