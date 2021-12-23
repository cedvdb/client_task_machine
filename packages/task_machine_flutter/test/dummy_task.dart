import 'package:task_machine/task_machine.dart';

typedef Input = int;
typedef Output = int;

class DoNothingTask extends Task<Input, Output> {
  int executionCount = 0;
  DoNothingTask({required int input}) : super(input: input);
  @override
  Future<void> execute() async {
    executionCount++;
  }
}

class AnException implements Exception {}
