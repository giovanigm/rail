import 'package:example/pages/examples/counter/counter_page_rail.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CounterPageRail rail;

  setUp(() {
    rail = CounterPageRail();
  });

  tearDown(() {
    rail.close();
  });

  test("", () async {
    expect(rail.stateStream, emitsInOrder([1, 2, 3]));
    rail.add();
    rail.add();
    rail.add();
    await rail.close();
  });
}
