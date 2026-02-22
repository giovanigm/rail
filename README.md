# Rail

[![codecov](https://codecov.io/gh/giovanigm/rail/graph/badge.svg?token=B9YX8Y0GYZ)](https://codecov.io/gh/giovanigm/rail)

Rail is a lightweight MVVM-inspired state management library for Flutter, heavily influenced by [orbit-mvi](https://orbit-mvi.org/) and [flutter_bloc](https://pub.dev/packages/flutter_bloc). It aims to provide a simple, testable, and predictable way to model application state and side-effects.

## Usage

Create a `Rail` that exposes a typed `state` and optional `effects`. Provide it to the widget tree with `RailProvider`, and read states in the UI with `RailBuilder` or `RailConsumer`.

Example:

```dart
// counter_effect.dart
sealed class CounterEffect {}

class CongratsMessageEffect extends CounterEffect {
  final int count;

  CongratsMessageEffect(this.count);
}

// counter_rail.dart
class CounterRail extends Rail<int, CounterEffect> {
  CounterRail() : super(initialState: 0);

  void increment() {
    final newCount = state + 1;
    emitState(newCount);
    if (newCount % 10 == 0) emitEffect(CongratsMessageEffect(newCount));
  }
}

// In your widget tree
RailProvider<CounterRail>(
  create: (_) => CounterRail(),
  child: Scaffold(
    body: Center(
      child: RailConsumer<CounterRail, int, CounterEffect>(
        listener: (context, effect) {
          if (effect is CongratsMessageEffect) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
              "Congrats! You pushed the button for incredible ${effect.count} times!",
            )));
          }
        },
        builder: (context, count) => Text('Count: $count'),
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => context.read<CounterRail>().increment(),
      child: Icon(Icons.add),
    ),
  ),
)
```

For more examples, see the [examples](./example/lib/pages/examples/) folder.

## Widgets

- `RailBuilder<RAIL, STATE>`: rebuilds UI when the `Rail` emits new states.
- `RailListener<RAIL, EFFECT>`: listen-only widget for reacting to effects.
- `RailConsumer<RAIL, STATE, EFFECT>`: combines state-driven building and effect-driven listening.

## Testing

`Rail` is designed for testability. Example unit test:

```dart
test('counter increments', () async {
  final rail = CounterRail();
  expect(rail.state, 0);
  rail.increment();
  expect(rail.state, 1);
  await rail.close();
});
```
<br/>

Testing your widgets with a real `Rail` is also simple:

```dart
void main() {  

  late CounterRail rail;

  setUp(() {
    rail = CounterRail();
  });

  tearDown(() {
    rail.close();
  });

  testWidgets("Should increment on button tap", (tester) async {
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
}
```
<br/>

Alternatively, you can mock your `Rail` using a lib like [mockito](https://pub.dev/packages/mockito):

```dart
import 'counter_page_test.mocks.dart';

@GenerateNiceMocks([MockSpec<CounterPageRail>()])
void main() {
  testWidgets("Should update counter text with rail state", (widgetTester) async {
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
}
```

For more testing examples, see the [example tests](./example/lib/pages/examples/test/pages/examples) folder.

## Contributing

- Read the existing tests and examples in `example/` and `test/` before adding new features.
- Open issues for bug reports or feature requests.
- Follow the repository coding style and include tests for new behavior.

