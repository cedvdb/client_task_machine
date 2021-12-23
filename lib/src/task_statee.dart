enum Status { ready, running, completed, closing }

class TaskState {
  Status get status;
  Object? get error;
  bool get isLoading;
  I get input;
  DataState<O>? get output;
}
