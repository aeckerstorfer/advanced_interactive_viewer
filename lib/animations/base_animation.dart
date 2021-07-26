import 'package:advanced_interactive_viewer/static_values/animation_duration.dart';
import 'package:flutter/material.dart';

class BaseAnimation {
  TransformationController transformationController;
  TickerProvider tickerProvider;
  AnimationSpeed animationSpeed;

  Animation<Matrix4>? animation;
  late final AnimationController controller;

  Matrix4 lastestDestination = Matrix4.identity();

  BaseAnimation(
    this.transformationController,
    this.tickerProvider,
    this.animationSpeed,
  ) {
    controller = AnimationController(
      vsync: tickerProvider,
      duration: animationSpeed.getDuration(),
    );
  }

  void changeAnimationSpeed(AnimationSpeed animationSpeed) {
    this.animationSpeed = animationSpeed;
    controller.duration = this.animationSpeed.getDuration();
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
    lastestDestination = endMatrix;
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

  void endCurrentAnimationIfRunning() {
    //get current status, so if the status is 'forward', we can jump to the
    //lastDestination
    var controllerStatus = controller.status;

    //reset controller to stop current animation
    controller.reset();

    if (controllerStatus == AnimationStatus.forward &&
        transformationController.value != lastestDestination) {
      transformationController.value = lastestDestination;
    }
  }
}
