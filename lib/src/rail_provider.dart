import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'rail.dart';

/// Provides a [Rail] created through the [create] function to descendant
/// widgets.
///
/// Widgets below in the tree can access the provided [Rail] through
/// `RailProvider.of(context)`.
///
/// ```dart
/// RailProvider<MyRail>() {
///   create: (context) => MyRail(),
///   child: const SizedBox(),
/// }
/// ```
///
/// Automatically closes the created [Rail]. If you want to retain the
/// Rail instance, use the [value] constructor.
///
/// The [Rail] instance will be created only when requested. For the
/// opposite behavior, set `lazy = false`.
class RailProvider<T extends Rail<Object?, Object?>>
    extends SingleChildStatelessWidget {
  const RailProvider({
    required Create<T> create,
    Key? key,
    this.child,
    this.lazy = true,
  })  : _create = create,
        _value = null,
        super(key: key, child: child);

  /// Passes a previously created instance of [Rail] to the tree below.
  ///
  /// Does not automatically close the [Rail], but ensure that it is
  /// created by a [RailProvider] higher in the tree using the [create]
  /// function so that it can be closed when no longer needed.
  const RailProvider.value({
    required T value,
    Key? key,
    this.child,
  })  : _value = value,
        _create = null,
        lazy = true,
        super(key: key, child: child);

  /// The child [Widget].
  final Widget? child;

  /// Controls wheter [create] will be called right away.
  ///
  /// The default value is `false`.
  final bool lazy;

  final Create<T>? _create;

  final T? _value;

  /// Function that allows descendant widgets of this [RailProvider] to
  /// access the provided [Rail] using:
  ///
  /// ```dart
  /// RailProvider.of<MyRail>(context);
  /// ```
  static T of<T extends Rail<Object?, Object?>>(
    BuildContext context, {
    bool listen = false,
  }) {
    try {
      return Provider.of<T>(context, listen: listen);
    } on ProviderNotFoundException catch (e) {
      if (e.valueType != T) rethrow;
      throw FlutterError(
        '''
        RailProvider.of() called with a context that does not contain a $T.
        No ancestor could be found starting from the context that was passed to RailProvider.of<$T>().

        This can happen if the context you used comes from a widget above the RailProvider.

        The context used was: $context
        ''',
      );
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final value = _value;
    return value != null
        ? InheritedProvider<T>.value(
            value: value,
            startListening: _startListening,
            lazy: lazy,
            child: child,
          )
        : InheritedProvider<T>(
            create: _create,
            dispose: (_, rail) => rail.close(),
            startListening: _startListening,
            lazy: lazy,
            child: child,
          );
  }

  static VoidCallback _startListening(
    InheritedContext<Rail<dynamic, dynamic>?> e,
    Rail<dynamic, dynamic> value,
  ) {
    final subscription = value.stateStream.listen(
      (dynamic _) => e.markNeedsNotifyDependents(),
    );
    return subscription.cancel;
  }
}
