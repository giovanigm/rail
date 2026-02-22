import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rail/rail.dart';

class _TestRail extends Rail<void, int> {
  _TestRail() : super(initialState: null);

  void increment() {
    emitEffect((lastEffect ?? 0) + 1);
  }
}

const _newRailKey = Key("new_rail");
const _sameRailKey = Key("same_rail");
const _incrementKey = Key("increment");

class _TestWidget extends StatefulWidget {
  final VoidCallback? onBuild;
  final void Function(int? previous, int current)? onReactToEffectWhenCalled;

  const _TestWidget({this.onBuild, this.onReactToEffectWhenCalled});

  @override
  State<_TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<_TestWidget> {
  late _TestRail rail;

  @override
  void initState() {
    rail = _TestRail();
    super.initState();
  }

  @override
  void dispose() {
    rail.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.onBuild?.call();
    return MaterialApp(
      home: Scaffold(
        body: RailListener<_TestRail, int>(
          rail: rail,
          listener: (context, effect) {},
          listenWhen: (previous, current) {
            widget.onReactToEffectWhenCalled?.call(previous, current);
            return true;
          },
          child: Column(
            children: [
              ElevatedButton(
                key: _newRailKey,
                onPressed: () {
                  setState(() {
                    rail = _TestRail();
                  });
                },
                child: const SizedBox(),
              ),
              ElevatedButton(
                key: _sameRailKey,
                onPressed: () {
                  setState(() => rail = rail);
                },
                child: const SizedBox(),
              ),
              ElevatedButton(
                key: _incrementKey,
                onPressed: () {
                  rail.increment();
                },
                child: const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  late _TestRail rail;

  setUp(() {
    rail = _TestRail();
  });

  tearDown(() {
    rail.close();
  });

  group("RailListener", () {
    testWidgets("should render child", (tester) async {
      const targetKey = Key('key');
      await tester.pumpWidget(
        RailListener<_TestRail, int>(
          rail: rail,
          listener: (context, effect) {},
          child: const SizedBox(key: targetKey),
        ),
      );
      expect(find.byKey(targetKey), findsOneWidget);
    });

    testWidgets("should call listener for every effect", (tester) async {
      final List<int> effects = [];

      await tester.pumpWidget(RailListener<_TestRail, int>(
        rail: rail,
        listener: (context, effect) {
          effects.add(effect);
        },
        child: const Placeholder(),
      ));

      rail.emitEffect(1);
      await tester.pump();

      expect(effects, [1]);

      rail.emitEffect(1);
      await tester.pump();

      rail.emitEffect(2);
      await tester.pump();

      expect(effects, [1, 1, 2]);
    });

    testWidgets(
        "should call listenWhen with correct previous effect and correct current effect",
        (tester) async {
      int? previousEffect;
      late int currentEffect;

      await tester.pumpWidget(RailListener<_TestRail, int>(
        rail: rail,
        listenWhen: (previous, current) {
          previousEffect = previous;
          currentEffect = current;
          return true;
        },
        listener: (context, effect) {},
        child: const Placeholder(),
      ));

      rail.emitEffect(1);
      await tester.pump();

      expect(previousEffect, null);
      expect(currentEffect, 1);

      rail.emitEffect(2);
      await tester.pump();

      expect(previousEffect, 1);
      expect(currentEffect, 2);
    });

    testWidgets("should call listener if listenWhen returns true",
        (tester) async {
      final List<int> effects = [];

      await tester.pumpWidget(RailListener<_TestRail, int>(
        rail: rail,
        listenWhen: (previous, current) => true,
        listener: (context, effect) {
          effects.add(effect);
        },
        child: const Placeholder(),
      ));

      rail.emitEffect(1);
      await tester.pump();

      expect(effects, [1]);

      rail.emitEffect(2);
      await tester.pump();

      expect(effects, [1, 2]);
    });

    testWidgets("should not call listener if listenWhen returns false",
        (tester) async {
      final List<int> effects = [];

      await tester.pumpWidget(RailListener<_TestRail, int>(
        rail: rail,
        listenWhen: (previous, current) => false,
        listener: (context, effect) {
          effects.add(effect);
        },
        child: const Placeholder(),
      ));

      rail.emitEffect(1);
      await tester.pump();

      expect(effects, []);

      rail.emitEffect(2);
      await tester.pump();

      expect(effects, []);
    });

    testWidgets("should not trigger builds on effects received",
        (tester) async {
      int builds = 0;
      await tester.pumpWidget(RailProvider(
        create: (context) => rail,
        child: _TestWidget(
          onBuild: () {
            builds++;
          },
        ),
      ));

      rail.emitEffect(1);
      await tester.pump();

      rail.emitEffect(2);
      await tester.pump();

      expect(builds, 1);
    });

    testWidgets(
        "should retrieve the Rail from the context if it is not provided",
        (tester) async {
      final List<int> effects = [];

      await tester.pumpWidget(
        RailProvider(
          create: (context) => rail,
          child: RailListener<_TestRail, int>(
            listener: (context, effect) => effects.add(effect),
            child: const SizedBox(),
          ),
        ),
      );

      rail.increment();
      await tester.pump();

      expect(effects, [1]);

      rail.increment();
      await tester.pump();

      expect(effects, [1, 2]);
    });

    testWidgets(
        "should keep subscription if Rail is changed at runtime to the same Rail",
        (tester) async {
      int? lastEffect;
      late int currentEffect;
      await tester.pumpWidget(_TestWidget(
        onReactToEffectWhenCalled: (previous, current) {
          lastEffect = previous;
          currentEffect = current;
        },
      ));

      await tester.tap(find.byKey(_incrementKey));
      await tester.pump();

      expect(lastEffect, null);
      expect(currentEffect, 1);

      await tester.tap(find.byKey(_sameRailKey));

      await tester.tap(find.byKey(_incrementKey));
      await tester.pump();

      expect(lastEffect, 1);
      expect(currentEffect, 2);
    });

    testWidgets(
        "should change subscription if Rail is changed at runtime to a different Rail",
        (tester) async {
      int? lastEffect;
      late int currentEffect;
      await tester.pumpWidget(_TestWidget(
        onReactToEffectWhenCalled: (previous, current) {
          lastEffect = previous;
          currentEffect = current;
        },
      ));

      await tester.tap(find.byKey(_incrementKey));
      await tester.pump();

      expect(lastEffect, null);
      expect(currentEffect, 1);

      await tester.tap(find.byKey(_newRailKey));

      await tester.tap(find.byKey(_incrementKey));
      await tester.pump();

      expect(lastEffect, null);
      expect(currentEffect, 1);
    });

    testWidgets("should update subscription when provided Rail is changed",
        (tester) async {
      final firstRail = _TestRail();
      final secondRail = _TestRail();

      final List<int> effects = [];

      await tester.pumpWidget(
        RailProvider.value(
          value: firstRail,
          child: RailListener<_TestRail, int>(
            listener: (context, effect) => effects.add(effect),
            child: const SizedBox(),
          ),
        ),
      );

      firstRail.increment();

      await tester.pumpWidget(
        RailProvider.value(
          value: secondRail,
          child: RailListener<_TestRail, int>(
            listener: (context, effect) => effects.add(effect),
            child: const SizedBox(),
          ),
        ),
      );

      secondRail.increment();
      await tester.pump();
      firstRail.increment();
      await tester.pump();

      expect(effects, [1, 1]);

      firstRail.close();
      secondRail.close();
    });
  });
}
