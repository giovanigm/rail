import 'package:rail/rail.dart';

import 'splash_page_effect.dart';

class SplashPageRail extends Rail<void, SplashPageEffect> {
  SplashPageRail() : super(initialState: null);

  Future<void> load() async {
    await Future.delayed(const Duration(seconds: 2));
    emitEffect(LoadedSplashEffect());
  }
}
