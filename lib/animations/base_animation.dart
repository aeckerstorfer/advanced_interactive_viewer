import 'package:flutter/material.dart';

class BaseAnimation {
  TransformationController transformationController;
  TickerProvider tickerProvider;
  Duration duration;

  Animation<Matrix4>? animation;
  late final AnimationController controller;

  BaseAnimation(
    this.transformationController,
    this.tickerProvider,
    this.duration,
  ) {
    print(duration);
    controller = AnimationController(
      vsync: tickerProvider,
      duration: duration,
    );
  }

  void _onAnimate() {
    transformationController.value = animation!.value;
    if (!controller.isAnimating) {
      animation!.removeListener(_onAnimate);
      animation = null;
      controller.reset();
    }
  }

  void startAnimation(endMatrix) {
    controller.reset();
    animation = Matrix4Tween(
      begin: transformationController.value,
      end: endMatrix,
    ).animate(controller);
    animation!.addListener(_onAnimate);
    controller.forward();
  }

  void stop() {
    controller.stop();
    animation?.removeListener(_onAnimate);
    animation = null;
    controller.reset();
  }

  void cancel() {
    if (controller.status == AnimationStatus.forward) {
      stop();
    }
  }
}
