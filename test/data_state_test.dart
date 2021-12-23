import 'package:test/test.dart';
import 'package:task_machine/task_machine.dart';

void main() {
  group('DataState', () {
    test('DataState.loaded', () {
      expect(DataState.loaded(3), isA<DataExists>());
      expect(DataState<int>.loaded(null), isA<DataNotExists>());
      expect(DataState<List<int>>.loaded([]), equals(isA<DataNotExists>()));
    });
  });
}
