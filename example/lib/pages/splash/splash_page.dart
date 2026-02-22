import 'package:flutter/material.dart';
import 'package:rail/rail.dart';

import 'splash_page_effect.dart';
import 'splash_page_rail.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RailListener<SplashPageRail, SplashPageEffect>(
      listener: (context, effect) {
        effect.when(
          loaded: (effect) =>
              Navigator.of(context).pushReplacementNamed(effect.route),
        );
      },
      child: const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 80, width: 80, child: FlutterLogo()),
              SizedBox(height: 24),
              Text(
                'rail',
                style: TextStyle(fontSize: 18),
              )
            ],
          ),
        ),
      ),
    );
  }
}
