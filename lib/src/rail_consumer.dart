import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'rail.dart';

/// A widget that uses both `States` and `Effects` emitted by the [Rail] to
/// construct new widgets and react to effects.
///
/// If you need to react only either to `States` or `Effects`, see
/// [RailBuilder] and [RailListener].
///
/// ```dart
/// RailConsumer<MyRail, MyState, MyEffect>() {
///   listener: (context, effect) {
///     // do something
///   },
///   builder: (context, state) {
///     return MyWidget();
///   },
/// }
/// ```
///
/// If [rail] is not provided, [RailConsumer] will look up the widget
/// tree using [RailProvider] and the current `BuildContext` for a
/// compatible Rail.
///
class RailConsumer<RAIL extends Rail<STATE, EFFECT>, STATE, EFFECT>
    extends StatefulWidget {
  const RailConsumer({
    Key? key,
    required this.builder,
    this.rail,
    this.listener,
    this.buildWhen,
    this.listenWhen,
  }) : super(key: key);

  /// The [Rail] that [RailConsumer] will react to.
  ///
  /// If [rail] is not provided, [RailConsumer] will look up the
  /// widget tree using [RailProvider] and the current `BuildContext` for a
  /// compatible Rail.
  final RAIL? rail;

  /// Builds a new widget every time the [rail] emits a new [state],
  /// and the [buildWhen] function returns true.
  final Widget Function(BuildContext context, STATE state) builder;

  /// Is invoked every time the [rail] emits a new [effect],
  /// and the [listenWhen] function returns true.
  final void Function(BuildContext context, EFFECT effect)? listener;

  /// Controls when [builder] should be called by using the [previous] state and
  /// the [current] state.
  ///
  /// The default behavior is to always call [builder] when receiving a new
  /// state from [rail].
  final bool Function(STATE previous, STATE current)? buildWhen;

  /// Controls when [listener] should be called by using the [previous] effect
  /// and the [current] state.
  ///
  /// The default behavior is to always call [listener] when receiving a new
  /// effect from [rail].
  final bool Function(EFFECT? previous, EFFECT current)? listenWhen;

  @override
  State<RailConsumer<RAIL, STATE, EFFECT>> createState() =>
      _RailConsumerState<RAIL, STATE, EFFECT>();
}

class _RailConsumerState<RAIL extends Rail<STATE, EFFECT>, STATE, EFFECT>
    extends State<RailConsumer<RAIL, STATE, EFFECT>> {
  late RAIL _rail;
  StreamSubscription<EFFECT>? _effectSubscription;
  StreamSubscription<STATE>? _stateSubscription;
  late STATE _state;
  EFFECT? _effect;

  @override
  void initState() {
    super.initState();
    _rail = widget.rail ?? context.read<RAIL>();
    _state = _rail.state;
    _effect = _rail.lastEffect;
    _subscribe();
  }

  @override
  void didUpdateWidget(RailConsumer<RAIL, STATE, EFFECT> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldRail = oldWidget.rail ?? context.read<RAIL>();
    final currentRail = widget.rail ?? oldRail;
    if (oldRail != currentRail) {
      if (_stateSubscription != null && _effectSubscription != null) {
        _rail = currentRail;
        _state = _rail.state;
        _effect = _rail.lastEffect;
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
      if (_stateSubscription != null && _effectSubscription != null) {
        _rail = rail;
        _state = _rail.state;
        _effect = _rail.lastEffect;
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

    final listener = widget.listener;
    if (listener != null) {
      _effectSubscription = _rail.effectStream.listen((effect) {
        if (widget.listenWhen?.call(_effect, effect) ?? true) {
          if (mounted) listener(context, effect);
        }
        _effect = effect;
      });
    }
  }

  void _unsubscribe() {
    _stateSubscription?.cancel();
    _stateSubscription = null;
    _effectSubscription?.cancel();
    _effectSubscription = null;
  }
}
