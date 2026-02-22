import 'package:flutter/material.dart';

class LoadingOverlay extends StatefulWidget {
  final Widget child;

  const LoadingOverlay({Key? key, required this.child}) : super(key: key);

  static LoadingOverlayState of(BuildContext context) {
    final loadingState = context.findAncestorStateOfType<LoadingOverlayState>();
    if (loadingState == null) {
      throw Exception("No Loading Overlay found in context");
    }
    return loadingState;
  }

  @override
  LoadingOverlayState createState() => LoadingOverlayState();
}

class LoadingOverlayState extends State<LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedLoadingOverlay(
      loadingOverlayState: this,
      child: Stack(
        children: [
          widget.child,
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Visibility(
                visible: controller.value != 0,
                child: Opacity(
                  opacity: controller.value,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.black.withOpacity(0.7),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  void close() {
    if (controller.isAnimating) {
      controller.stop();
      controller.reverse();
      return;
    }

    controller.reverse();
  }

  void open() {
    if (controller.isAnimating) {
      controller.stop();
      controller.forward();
      return;
    }

    controller.forward();
  }

  bool get isOpen => controller.isCompleted;
}

class _InheritedLoadingOverlay extends InheritedWidget {
  final LoadingOverlayState loadingOverlayState;

  const _InheritedLoadingOverlay({
    Key? key,
    required this.loadingOverlayState,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedLoadingOverlay oldWidget) {
    return oldWidget.loadingOverlayState != loadingOverlayState;
  }
}
