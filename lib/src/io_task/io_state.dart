import 'data_state.dart';

class IOtate<I, O> {
  final DataState<I> input;
  final DataState<O> output;

  bool get isStarted => input is! DataUnset;
  bool get isNotStarted => input is DataUnset;
  bool get isLoading => output is DataLoading;
  bool get isLoaded => output is DataLoaded;

  IOtate._({
    required this.input,
    required this.output,
  });

  IOtate.unstarted()
      : input = const DataUnset(),
        output = const DataUnset();

  IOtate<I, O> copyWith({
    DataState<I>? input,
    DataState<O>? output,
  }) {
    return IOtate<I, O>._(
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
