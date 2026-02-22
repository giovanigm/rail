import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'rail.dart';

/// A widget that uses `States` emitted by the [Rail] to construct new
/// widgets through the [builder] function.
///
/// If you also need to react to `Effects`, please see [RailConsumer].
///
/// ```dart
/// RailBuilder<MyRail, MyState>() {
///   builder: (context, state) {
///     return MyWidget();
///   },
/// }
/// ```
///
/// If [rail] is not provided, [RailBuilder] will look up the widget
/// tree using [RailProvider] and the current `BuildContext` for a
/// compatible Rail.
///
class RailBuilder<RAIL extends Rail<STATE, dynamic>, STATE>
    extends StatefulWidget {
  const RailBuilder({
    Key? key,
    required this.builder,
    this.rail,
    this.buildWhen,
  }) : super(key: key);

  /// The [Rail] that [RailBuilder] will react to.
  ///
  /// If [rail] is not provided, [RailBuilder] will look up the widget
  /// tree using [RailProvider] and the current `BuildContext` for a
  /// compatible Rail.
  final RAIL? rail;

  /// Builds a new widget every time the [rail] emits a new [state],
  /// and the [buildWhen] function returns true.
  final Widget Function(BuildContext context, STATE state) builder;

  /// Controls when [builder] should be called by using the [previous] state and
  /// the [current] state.
  ///
  /// The default behavior is to always call [builder] when receiving a new
  /// state from [rail].
  final bool Function(STATE previous, STATE current)? buildWhen;

  @override
  State<RailBuilder<RAIL, STATE>> createState() =>
      _RailBuilderState<RAIL, STATE>();
}

class _RailBuilderState<RAIL extends Rail<STATE, dynamic>, STATE>
    extends State<RailBuilder<RAIL, STATE>> {
  late RAIL _rail;
  StreamSubscription<STATE>? _stateSubscription;
  late STATE _state;

  @override
  void initState() {
    super.initState();
    _rail = widget.rail ?? context.read<RAIL>();
    _state = _rail.state;
    _subscribe();
  }

  @override
  void didUpdateWidget(RailBuilder<RAIL, STATE> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldRail = oldWidget.rail ?? context.read<RAIL>();
    final currentRail = widget.rail ?? oldRail;
    if (oldRail != currentRail) {
      if (_stateSubscription != null) {
        _rail = currentRail;
        _state = _rail.state;
        _unsubscribe();
      }
      _subscribe();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final rail = widget.rail ?? context.read<RAIL>();
    if (_rail != rail) {
      if (_stateSubscription != null) {
        _rail = rail;
        _state = _rail.state;
        _unsubscribe();
      }
      _subscribe();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rail == null) {
      context.select<RAIL, bool>((rail) => identical(_rail, rail));
    }

    return widget.builder(context, _state);
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    _stateSubscription = _rail.stateStream.listen((state) {
      if (widget.buildWhen?.call(_state, state) ?? true) {
        setState(() {});
      }
      _state = state;
    });
  }

  void _unsubscribe() {
    _stateSubscription?.cancel();
    _stateSubscription = null;
  }
}
