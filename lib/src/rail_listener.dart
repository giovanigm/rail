import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'rail.dart';

/// A Widget that reacts to `Effects` emitted by [Rail] and invokes
/// [listener] callback.
///
/// It should be used when you only need to deal with side effects such as
/// navigating after some validation, displaying feedback SnackBars, and similar
/// cases.
///
/// If you also need to react to `States`, please see [RailConsumer].
///
/// ```dart
/// RailListener<MyRail, MyEffect>() {
///   listener: (context, effect) {
///     // do something
///   },
///   child: const SizedBox(),
/// }
/// ```
///
/// If [rail] is not provided, [RailListener] will look up the widget
/// tree using [RailProvider] and the current `BuildContext` for a
/// compatible Rail.
///
class RailListener<RAIL extends Rail<dynamic, EFFECT>, EFFECT>
    extends StatefulWidget {
  const RailListener({
    Key? key,
    this.rail,
    required this.listener,
    this.listenWhen,
    required this.child,
  }) : super(key: key);

  /// The [Rail] that [RailListener] will listen to.
  ///
  /// If [rail] is not provided, [RailListener] will look up the
  /// widget tree using [RailProvider] and the current `BuildContext` for a
  /// compatible Rail.
  final RAIL? rail;

  /// Is invoked every time the [rail] emits a new [effect],
  /// and the [listenWhen] function returns true.
  final void Function(BuildContext context, EFFECT effect) listener;

  /// Controls when [listener] should be called by using the [previous] effect
  /// and the [current] state.
  ///
  /// The default behavior is to always call [listener] when receiving a new
  /// effect from [rail].
  final bool Function(EFFECT? previous, EFFECT current)? listenWhen;

  /// The Widget to be rendered.
  final Widget child;

  @override
  State<RailListener<RAIL, EFFECT>> createState() =>
      _RailListenerState<RAIL, EFFECT>();
}

class _RailListenerState<RAIL extends Rail<dynamic, EFFECT>, EFFECT>
    extends State<RailListener<RAIL, EFFECT>> {
  late RAIL _rail;
  StreamSubscription<EFFECT>? _effectSubscription;
  EFFECT? _effect;

  @override
  void initState() {
    super.initState();
    _rail = widget.rail ?? context.read<RAIL>();
    _effect = _rail.lastEffect;
    _subscribe();
  }

  @override
  void didUpdateWidget(RailListener<RAIL, EFFECT> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldRail = oldWidget.rail ?? context.read<RAIL>();
    final currentRail = widget.rail ?? oldRail;
    if (oldRail != currentRail) {
      if (_effectSubscription != null) {
        _rail = currentRail;
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
      if (_effectSubscription != null) {
        _rail = rail;
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

    return widget.child;
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    _effectSubscription = _rail.effectStream.listen((effect) {
      if (widget.listenWhen?.call(_effect, effect) ?? true) {
        if (mounted) widget.listener.call(context, effect);
      }
      _effect = effect;
    });
  }

  void _unsubscribe() {
    _effectSubscription?.cancel();
    _effectSubscription = null;
  }
}
