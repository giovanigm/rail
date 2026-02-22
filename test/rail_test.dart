import 'package:flutter_test/flutter_test.dart';
import 'package:rail/src/rail.dart';

class TestRail extends Rail<int, int> {
  TestRail() : super(initialState: 0);
}

void main() {
  late TestRail rail;

  setUp(() {
    rail = TestRail();
  });

  tearDown(() async {
    await rail.close();
  });

  group("state", () {
    test("should return initial state", () {
      expect(rail.state, 0);
    });

    test("should return current state", () {
      rail.emitState(1);
      expect(rail.state, 1);
    });
  });

  group("lastEffect", () {
    test("should emit null if no effect was emitted", () {
      expect(rail.lastEffect, null);
    });

    test("should emit last effect", () {
      rail.emitEffect(1);
      expect(rail.lastEffect, 1);
    });
  });

  group("emitState", () {
    test("should emit states in correct order", () async {
      expect(rail.stateStream, emitsInOrder([1, 2, 3, emitsDone]));
      rail.emitState(1);
      rail.emitState(2);
      rail.emitState(3);
      await rail.close();
    });

    test("should not emit new states after close", () async {
      expect(rail.stateStream, emitsInOrder([1, 2, emitsDone]));
      rail.emitState(1);
      rail.emitState(2);
      await rail.close();
      rail.emitState(3);
    });

    test("should not emit the same state", () async {
      expect(rail.stateStream, emitsInOrder([1, 2, emitsDone]));
      rail.emitState(1);
      rail.emitState(1);
      rail.emitState(2);
      rail.emitState(2);
      await rail.close();
    });
  });

  group("emitEffect", () {
    test("should emit effects in correct order", () async {
      expect(rail.effectStream, emitsInOrder([1, 2, 3, emitsDone]));
      rail.emitEffect(1);
      rail.emitEffect(2);
      rail.emitEffect(3);
      await rail.close();
    });

    test("should not emit new effects after close", () async {
      expect(rail.effectStream, emitsInOrder([1, 2, emitsDone]));
      rail.emitEffect(1);
      rail.emitEffect(2);
      await rail.close();
      rail.emitEffect(3);
    });

    test("should allow emit the same effect", () async {
      expect(rail.effectStream, emitsInOrder([1, 1, 2, 2, emitsDone]));
      rail.emitEffect(1);
      rail.emitEffect(1);
      rail.emitEffect(2);
      rail.emitEffect(2);
      await rail.close();
    });
  });

  group("close", () {
    test("should close stateStream", () async {
      await rail.close();
      expect(rail.effectStream, emitsDone);
    });

    test("should close effectStream", () async {
      await rail.close();
      expect(rail.effectStream, emitsDone);
    });
  });
}
