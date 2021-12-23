import 'package:equatable/equatable.dart';

abstract class DataState<O> {
  factory DataState.loaded(O? data) {
    if (data == null || (data is List && data.isEmpty)) {
      return const DataNotExists();
    }
    return DataExists<O>(data);
  }
}

class DataExists<O> with EquatableMixin implements DataState<O> {
  final O data;
  const DataExists(this.data);

  @override
  List<Object?> get props => [data];
}

class DataNotExists<O> with EquatableMixin implements DataState<O> {
  const DataNotExists();

  @override
  List<Object?> get props => [];
}
