abstract class TaskState<I, O> with EquatableMixin {
  Status get status;
  Object? get error;
  bool get isLoading;
  I get input;
  DataState<O>? get output;

  @override
  List<Object?> get props => [status, error, isLoading, input, output];
}
