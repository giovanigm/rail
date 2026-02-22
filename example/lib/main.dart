import 'package:flutter/material.dart';
import 'package:rail/rail.dart';

import 'pages/main/main_page.dart';
import 'pages/splash/splash_page.dart';
import 'pages/splash/splash_page_rail.dart';
import 'pages/widgets/loading_overlay.dart';

void main() {
  runApp(const MainApp());
}

final routes = {
  '/main': (_) => const MainPage(),
  '/': (context) => RailProvider<SplashPageRail>(
        create: (_) => SplashPageRail()..load(),
        child: const SplashPage(),
      ),
};

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(useMaterial3: true).copyWith(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
      ),
      builder: (context, child) =>
          LoadingOverlay(child: child ?? const Placeholder()),
      routes: routes,
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
    );
  }
}
