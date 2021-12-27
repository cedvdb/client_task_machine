abstract class ReadState<I, O> {
  const ReadState();
}

/// data not yet loading
class ReadUnstarted<I, O> implements ReadState<I, O> {
  const ReadUnstarted();
}

abstract class ReadStarted<I, O> implements ReadState<I, O> {
  I get input;
}

/// data is loading
class ReadLoading<I, O> implements ReadStarted<I, O> {
  @override
  final I input;
  const ReadLoading({required this.input});

  @override
  String toString() => 'ReadLoading(input: $input)';
}

/// error while loading the data
class ReadError<I, O> implements ReadStarted<I, O> {
  @override
  final I input;
  final Object error;

  const ReadError({
    required this.input,
    required this.error,
  });

  @override
  String toString() => 'ReadError(input: $input, error: $error)';
}

abstract class ReadCompleted<I, O> implements ReadStarted<I, O> {
  @override
  I get input;
  O? get output;

  /// defines whether new data is being loaded
  bool get isUpdating;

  factory ReadCompleted.build({
    required I input,
    required O? output,
    bool isUpdating = false,
  }) {
    if (output == null || (output is List && output.isEmpty)) {
      return ReadCompletedWithoutData(
        input: input,
        isUpdating: isUpdating,
        output: output,
      );
    }
    return ReadCompletedWithData(
      input: input,
      isUpdating: isUpdating,
      output: output,
    );
  }
}

class ReadCompletedWithData<I, O> implements ReadCompleted<I, O> {
  @override
  final I input;
  @override
  final bool isUpdating;
  @override
  final O output;

  const ReadCompletedWithData({
    required this.input,
    required this.isUpdating,
    required this.output,
  });
}

class ReadCompletedWithoutData<I, O> implements ReadCompleted<I, O> {
  @override
  final I input;
  @override
  final bool isUpdating;
  @override
  final O? output;

  const ReadCompletedWithoutData({
    required this.input,
    required this.isUpdating,
    required this.output,
  });
}
