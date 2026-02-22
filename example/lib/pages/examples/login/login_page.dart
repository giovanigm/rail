import 'package:flutter/material.dart';
import 'package:rail/rail.dart';

import '../../widgets/example_text_field.dart';
import '../../widgets/loading_overlay.dart';
import 'login_page_effect.dart';
import 'login_page_state.dart';
import 'login_page_rail.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RailConsumer<LoginPageRail, LoginPageState, LoginPageEffect>(
      listener: (context, effect) {
        FocusScope.of(context).unfocus();
        effect.when(
          startLoading: () => LoadingOverlay.of(context).open(),
          stopLoading: () => LoadingOverlay.of(context).close(),
          showError: (message) => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message))),
          onAuthenticated: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("User Authenticated!"))),
        );
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text("Login")),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const SizedBox(height: 80, width: 80, child: FlutterLogo()),
                  const SizedBox(
                    height: 32,
                  ),
                  ExampleTextField(
                    hintText: "Email",
                    onChanged: context.read<LoginPageRail>().setEmail,
                    errorText: state.emailTextError,
                    success: state.isValidEmail,
                    helperText: "Try 'email@email.com'",
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  ExampleTextField(
                    hintText: "Password",
                    onChanged: context.read<LoginPageRail>().setPassword,
                    obscureText: true,
                    errorText: state.passwordTextError,
                    success: state.isValidPassword,
                    helperText: "Try '123456'",
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  FilledButton(
                    onPressed: state.isValidPassword && state.isValidEmail
                        ? () async =>
                            await context.read<LoginPageRail>().login()
                        : null,
                    style: FilledButton.styleFrom(
                      disabledBackgroundColor: Theme.of(context).disabledColor,
                    ),
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
