abstract class DataState<O> {
  const DataState();
}

/// data not yet loading
class DataUnset<O> implements DataState<O> {
  const DataUnset();
}

/// data is loading
class DataLoading<O> implements DataState<O> {
  const DataLoading();
}

/// error while loading the data
class DataError<O> implements DataState<O> {
  final Object error;

  const DataError(this.error);
}

abstract class DataLoaded<O> implements DataState<O> {
  O? get data;

  factory DataLoaded(O? output) {
    if (output == null || (output is List && output.isEmpty)) {
      return DataExists(output);
    }
    return DataNotExists(output);
  }
}

class DataNotExists<O> implements DataLoaded<O> {
  @override
  final O data;

  const DataNotExists(this.data);
}

class DataExists<O> implements DataLoaded<O> {
  @override
  final O? data;

  const DataExists(this.data);
}
