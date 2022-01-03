import 'data_state.dart';

class IOState<I, O> {
  final I? input;

  final DataState<O> output;

  bool get isStarted => output is! DataUnset;
  bool get isNotStarted => output is DataUnset;
  bool get isLoading => output is DataLoading;
  bool get isLoaded => output is DataLoaded;

  IOState._({
    required this.input,
    required this.output,
  });

  const IOState.unstarted()
      : output = const DataUnset(),
        input = null;

  IOState<I, O> copyWith({
    I? input,
    DataState<O>? output,
  }) {
    return IOState<I, O>._(
      input: input ?? this.input,
      output: output ?? this.output,
    );
  }
}

// abstract class ReadState<I, O> {
//   DataState<O> get output;
//   const ReadState();
// }

// class ReadUnstarted<I, O> extends ReadState<I, O> {
//   @override
//   final DataState<O> output = const DataUnset();
// }

// abstract class ReadStarted<I, O> extends ReadState<I, O> {
//   final I input;
//   @override
//   final DataState<O> output;

//   const ReadStarted(this.input, this.output);
// }

// class ReadLoading<I, O> extends ReadStarted<I, O> {
//   const ReadLoading(I input) : super(input, const DataLoading());
// }

// class ReadCompleted<I, O> extends ReadStarted<I, O> {
//   ReadCompleted({required I input, required O output})
//       : super(input, DataLoaded(output: output));
// }
