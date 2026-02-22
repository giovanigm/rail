import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rail/rail.dart';

class TestRail extends Rail<int, int> {
  VoidCallback? onClose;
  TestRail({this.onClose}) : super(initialState: 0);

  @override
  Future<void> close() {
    onClose?.call();
    return super.close();
  }
}

void main() {
  late TestRail rail;

  setUp(() {
    rail = TestRail();
  });

  tearDown(() {
    rail.close();
  });

  group("RailProvider", () {
    testWidgets("lazily loads Rails by default", (tester) async {
      bool isCreated = false;
      await tester.pumpWidget(
        RailProvider(
          create: (_) {
            isCreated = true;
            return rail;
          },
          child: const SizedBox(),
        ),
      );
      expect(isCreated, isFalse);
    });

    testWidgets("can override lazy loading", (tester) async {
      bool isCreated = false;
      await tester.pumpWidget(
        RailProvider(
          lazy: false,
          create: (_) {
            isCreated = true;
            return rail;
          },
          child: const SizedBox(),
        ),
      );
      expect(isCreated, isTrue);
    });

    testWidgets("provides Rail to children", (tester) async {
      const buttonKey = Key("button");
      int? state;
      await tester.pumpWidget(
        MaterialApp(
          home: RailProvider(
            lazy: false,
            create: (_) => rail,
            child: Builder(builder: (context) {
              return ElevatedButton(
                key: buttonKey,
                onPressed: () {
                  state = RailProvider.of<TestRail>(context).state;
                },
                child: const Text(""),
              );
            }),
          ),
        ),
      );

      await tester.tap(find.byKey(buttonKey));
      expect(state, 0);
    });

    testWidgets(
        "should throw FlutterError if RailProvider is not found in current context",
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              RailProvider.of<TestRail>(context);
              return const SizedBox();
            },
          ),
        ),
      );
      final dynamic exception = tester.takeException();
      const expectedMessage = '''
        RailProvider.of() called with a context that does not contain a TestRail.
        No ancestor could be found starting from the context that was passed to RailProvider.of<TestRail>().

        This can happen if the context you used comes from a widget above the RailProvider.

        The context used was: Builder(dirty)
''';
      expect((exception as FlutterError).message, expectedMessage);
    });

    testWidgets("does not close Rail if it was not loaded", (tester) async {
      const buttonKey = Key("button");
      bool isClosed = false;
      final rail = TestRail(onClose: () => isClosed = true);
      await tester.pumpWidget(
        MaterialApp(
          home: RailProvider(
            create: (_) => rail,
            child: Builder(builder: (context) {
              return ElevatedButton(
                key: buttonKey,
                onPressed: () =>
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const SizedBox(),
                )),
                child: const Text(""),
              );
            }),
          ),
        ),
      );

      expect(isClosed, false);

      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      expect(isClosed, false);
      rail.close();
    });

    testWidgets("closes Rail automatically when invoked", (tester) async {
      const buttonKey = Key("button");
      bool isClosed = false;
      final rail = TestRail(onClose: () => isClosed = true);
      await tester.pumpWidget(
        MaterialApp(
          home: RailProvider(
            create: (_) => rail,
            child: Builder(builder: (context) {
              RailProvider.of<TestRail>(context);
              return ElevatedButton(
                key: buttonKey,
                onPressed: () =>
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const SizedBox(),
                )),
                child: const Text(""),
              );
            }),
          ),
        ),
      );

      expect(isClosed, false);

      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      expect(isClosed, true);
      rail.close();
    });

    testWidgets("does not close when created using value", (tester) async {
      const buttonKey = Key("button");
      bool isClosed = false;
      final rail = TestRail(onClose: () => isClosed = true);
      await tester.pumpWidget(
        MaterialApp(
          home: RailProvider.value(
            value: rail,
            child: Builder(builder: (context) {
              RailProvider.of<TestRail>(context);
              return ElevatedButton(
                key: buttonKey,
                onPressed: () =>
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const SizedBox(),
                )),
                child: const Text(""),
              );
            }),
          ),
        ),
      );

      expect(isClosed, false);

      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      expect(isClosed, false);
      rail.close();
    });
  });
}
