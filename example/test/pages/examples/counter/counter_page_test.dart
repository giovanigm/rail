import 'package:example/pages/examples/counter/counter_page.dart';
import 'package:example/pages/examples/counter/counter_page_rail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rail/rail.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'counter_page_test.mocks.dart';

@GenerateNiceMocks([MockSpec<CounterPageRail>()])
void main() {
  group("Counter Page", () {
    setUp(() {});

    testWidgets("Mock Rail", (widgetTester) async {
      final rail = MockCounterPageRail();

      when(rail.state).thenReturn(2);

      await widgetTester.pumpWidget(MaterialApp(
        home: RailProvider<CounterPageRail>(
          create: (context) => rail,
          child: const CounterPage(),
        ),
      ));

      expect(find.text('2'), findsOneWidget);
    });
  });

  group("Counter Page", () {
    late CounterPageRail rail;

    setUp(() {
      rail = CounterPageRail();
    });

    tearDown(() {
      rail.close();
    });

    testWidgets("Real Rail", (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: RailProvider(
          create: (context) => rail,
          child: const CounterPage(),
        ),
      ));

      expect(find.text('0'), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      expect(find.text('2'), findsOneWidget);
    });
  });
}
