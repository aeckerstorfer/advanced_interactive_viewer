import 'package:advanced_interactive_viewer/animations/base_animation.dart';
import 'package:flutter/material.dart';

class ResetAnimation extends BaseAnimation {
  ResetAnimation({
    required transformationController,
    required tickerProvider,
    duration = const Duration(milliseconds: 400),
  }) : super(transformationController, tickerProvider, duration);

  void start() {
    super.startAnimation(Matrix4.identity());
  }
}
