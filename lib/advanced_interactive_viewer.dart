library advanced_interactive_viewer;

import 'package:advanced_interactive_viewer/animations/reset_animation.dart';
import 'package:advanced_interactive_viewer/animations/translate_animation.dart';
import 'package:advanced_interactive_viewer/static_values/animation_duration.dart';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';

class AdvancedInteractiveViewer extends StatefulWidget {
  AdvancedInteractiveViewer({
    Key? key,
    this.child = const Text("No Child set!"),
    this.showFooter = false,
    this.animationSpeed = AnimationSpeed.MEDIUM,
    this.minScale = 0.1,
    this.maxScale = 10,
    this.onInteractionStart,
    this.afterInitCallback,
    this.isCentered = true,
    this.offsetToCenter,
  }) : super(key: key);

  Widget child;
  final bool showFooter;
  final bool isCentered;
  final AnimationSpeed animationSpeed;
  final double minScale;
  final double maxScale;
  final Offset? offsetToCenter;
  final Function(ScaleStartDetails details)? onInteractionStart;
  final Function? afterInitCallback;

  late final _AdvancedInteractiveViewerState _state;

  @override
  _AdvancedInteractiveViewerState createState() {
    _state = _AdvancedInteractiveViewerState();
    return _state;
  }

  void translateTo(Offset position) =>
      _state.translateAnimation.translateTo(position);

  void translateToWithOffset(Offset position, Offset offset) =>
      _state.translateAnimation.translateTo(position, withOffset: offset);

  void translate(double x, double y) =>
      _state.translateAnimation.translate(x, y);

  void scaleAndTranslateToPosition(double scale, Offset position) =>
      _state.translateAnimation.scaleAndTranslateToPosition(scale, position);

  void scale(double scale) => _state.translateAnimation.scale(scale);

  void reset() => _state.resetAnimation.start();
}

class _AdvancedInteractiveViewerState extends State<AdvancedInteractiveViewer>
    with AfterLayoutMixin<AdvancedInteractiveViewer>, TickerProviderStateMixin {
  // Transformation Controller and Animators
  late TransformationController _transformationController;
  late ResetAnimation resetAnimation;
  late TranslateAnimation translateAnimation;

  // Global Key to get the Size of the child
  GlobalKey _childKey = GlobalKey();

  //Animation Speed
  late AnimationSpeed animationSpeed;

  //Gets triggered when a user input is detected
  void _onInteractionStart(ScaleStartDetails details) {
    // If the user tries to cause a transformation while the reset animation is
    // running, cancel the reset animation.
    resetAnimation.cancel();
    translateAnimation.cancel();

    if (widget.onInteractionStart != null) widget.onInteractionStart!(details);
  }

  @override
  void initState() {
    super.initState();

    animationSpeed = widget.animationSpeed;

    _transformationController = TransformationController();

    resetAnimation = ResetAnimation(
      transformationController: _transformationController,
      tickerProvider: this,
      animationSpeed: animationSpeed,
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    var offsetToCenter = widget.isCentered
        ? (widget.offsetToCenter ?? _calcOffsetToCenter())
        : Offset.zero;

    print(offsetToCenter);
    print(widget.offsetToCenter);

    translateAnimation = TranslateAnimation(
      transformationController: _transformationController,
      tickerProvider: this,
      animationSpeed: animationSpeed,
      baseOffset: offsetToCenter,
    );

    widget.afterInitCallback!();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
        key: _childKey,
        constrained: false,
        transformationController: _transformationController,
        onInteractionStart: _onInteractionStart,
        boundaryMargin: const EdgeInsets.all(double.infinity),
        minScale: widget.minScale,
        maxScale: widget.maxScale,
        child: widget.child);
  }

  Offset _calcOffsetToCenter() {
    Size childSize = _childKey.currentContext?.size ?? Size(0, 0);

    var xToCenter = childSize.width / 2;
    var yToCenter = childSize.height / 2;

    print("$xToCenter and $yToCenter");
    return Offset(xToCenter, yToCenter);
  }
}
