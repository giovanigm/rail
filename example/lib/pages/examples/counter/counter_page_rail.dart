import 'package:rail/rail.dart';

class CounterPageRail extends Rail<int, void> {
  CounterPageRail() : super(initialState: 0);

  void add() {
    final newState = state + 1;
    emitState(newState);
  }
}
