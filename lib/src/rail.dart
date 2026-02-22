import 'dart:async';

import 'package:flutter/foundation.dart';

/// A [Rail] can manage the `State` of a View and send `Effects` to it.
///
/// Every [Rail] requires an initial state which will be the
/// state of the [Rail] before [emitState] has been called.
///
/// The current state of a [Rail] can be accessed via the [state] getter
/// and the last effect emitted can be accessed via the [lastEffect] getter.
///
/// ```dart
/// class MyRail extends Rail<MyState, MyEffect> {
///   MyRail() : super(initialState: MyState());
///
///   void doSomething() {
///     emitState(MyState());
///     emitEffect(MyEffect());
///   }
/// }
/// ```
abstract class Rail<State, Effect> {
  Rail({required State initialState}) {
    _state = initialState;
  }

  late State _state;

  Effect? _effect;

  late final _stateController = StreamController<State>.broadcast();

  late final _effectController = StreamController<Effect>.broadcast();

  /// The current [state]
  State get state => _state;

  /// The last effect
  Effect? get lastEffect => _effect;

  /// The state stream
  ///
  /// Will be canceled after [close] is called.
  Stream<State> get stateStream => _stateController.stream;

  /// The effect stream
  ///
  /// Will be canceled after [close] is called.
  Stream<Effect> get effectStream => _effectController.stream;

  /// Whether the [Rail] is closed.
  ///
  /// A [Rail] is considered closed once [close] is called.
  bool isClosed = false;

  ///Emits a new [state] to its subscribers.
  ///
  /// This method is responsible for handling the emission of states. It checks
  /// if the Rail is closed before attempting to emit a new state.
  ///
  /// Parameters:
  /// - [state]: The new state to be emitted by the Rail.
  ///
  /// If the Rail is closed, a debug message is printed, and the state
  /// emission is skipped.
  /// If the provided state is equal to the current state, the emission is also
  /// skipped.
  /// Otherwise, the new state is set, and it is added to the state controller.
  ///
  /// Throws:
  /// - If an error occurs during the state emission, it is rethrown.
  void emitState(State state) {
    try {
      if (isClosed) {
        debugPrint('Cannot emit new states after calling close');
        return;
      }
      if (state == _state) return;
      _state = state;
      _stateController.add(_state);
    } catch (error) {
      rethrow;
    }
  }

  /// Emits a new [effect] to its subscribers.
  ///
  /// This method is responsible for handling the emission of effects. It checks
  /// if the Rail is closed before attempting to emit a new effect.
  ///
  /// Parameters:
  /// - [effect]: The new effect to be emitted by the Rail.
  ///
  /// If the Rail is closed, a debug message is printed, and the effect emission is skipped.
  /// Otherwise, the new effect is set, and it is added to the effect controller.
  ///
  /// Throws:
  /// - If an error occurs during the effect emission, it is rethrown.
  void emitEffect(Effect effect) {
    try {
      if (isClosed) {
        debugPrint('Cannot emit new effects after calling close');
        return;
      }
      _effect = effect;
      _effectController.add(effect);
    } catch (error) {
      rethrow;
    }
  }

  /// Closes the Rail, completing associated controllers.
  ///
  /// It closes the state and effect controllers, marking the Rail as closed.
  ///
  /// During the close operation, the state controller and effect controller are closed using
  /// asynchronous operations, and the isClosed flag is set to true.
  ///
  /// Subclasses should call super.close() as part of their overridden close methods.
  ///
  /// Throws:
  /// - Any error that occurs during the closing of controllers is propagated.
  @mustCallSuper
  Future<void> close() async {
    await _stateController.close();
    await _effectController.close();
    isClosed = true;
  }
}
