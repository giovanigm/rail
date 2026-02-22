import 'package:rail/rail.dart';

import 'login_page_effect.dart';
import 'login_page_state.dart';

class LoginPageRail extends Rail<LoginPageState, LoginPageEffect> {
  LoginPageRail() : super(initialState: LoginPageState.initialState());

  static const _correctEmail = 'email@email.com';
  static const _correctPassword = '123456';
  String _email = '';
  String _password = '';
  final RegExp _emailRegExp =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  void setEmail(String value) {
    _email = value;

    final validEmail = _emailRegExp.hasMatch(value);
    emitState(validEmail ? state.validEmail() : state.invalidEmail());
  }

  void setPassword(String value) {
    _password = value;

    final validPassword = value.length >= 6;
    emitState(validPassword ? state.validPassword() : state.invalidPassword());
  }

  Future<void> login() async {
    try {
      emitEffect(LoadingLoginEffect.start());
      await Future.delayed(const Duration(seconds: 2));

      if (_correctEmail != _email || _correctPassword != _password) {
        emitEffect(LoadingLoginEffect.stop());
        emitEffect(
            AuthenticationErrorLoginEffect("Incorrect email or password"));
        return;
      }

      emitEffect(LoadingLoginEffect.stop());
      emitEffect(AuthenticatedLoginEffect());
    } catch (error) {
      emitEffect(LoadingLoginEffect.stop());
      emitEffect(AuthenticationErrorLoginEffect("Something wrong happened!"));
    }
  }
}
