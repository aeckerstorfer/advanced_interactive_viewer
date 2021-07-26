import 'package:advanced_interactive_viewer/animations/base_animation.dart';
import 'package:advanced_interactive_viewer/static_values/animation_duration.dart';
import 'package:flutter/material.dart';

class ResetAnimation extends BaseAnimation {
  ResetAnimation({
    required transformationController,
    required tickerProvider,
    animationSpeed = AnimationSpeed.MEDIUM,
  }) : super(transformationController, tickerProvider, animationSpeed);

  void start() {
    super.startAnimation(Matrix4.identity());
  }
}
