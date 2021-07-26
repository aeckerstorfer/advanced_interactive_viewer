import 'package:advanced_interactive_viewer/animations/base_animation.dart';
import 'package:advanced_interactive_viewer/static_values/animation_duration.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

class TranslateAnimation extends BaseAnimation {
  GlobalKey childKey;

  TranslateAnimation({
    required transformationController,
    required tickerProvider,
    required this.childKey,
    animationSpeed = AnimationSpeed.MEDIUM,
  }) : super(transformationController, tickerProvider, animationSpeed);

  void translate(double x, double y) {
    super.endCurrentAnimationIfRunning();

    Matrix4 endMatrix = transformationController.value.clone();
    endMatrix.translate(x, y);

    super.startAnimation(endMatrix);
  }

  void translateTo(Offset destination) {
    super.endCurrentAnimationIfRunning();

    Matrix4 endMatrix = transformationController.value.clone();

    Vector3 scale = _getScale(endMatrix);

    Offset offset = _calculateDestinationBasedOnScale(destination, scale);

    endMatrix.translate(offset.dx, offset.dy);

    super.startAnimation(endMatrix);
  }

  void scaleAndTranslateToPosition(double scale, Offset destination) {
    super.endCurrentAnimationIfRunning();

    //get distance to center
    //distance to center is the starting point (the left upper corner)
    var distanceToCenter = _getDistanceToCenter();

    //subtract destionation from the starting point to "move" to the destination
    destination = distanceToCenter - destination;

    var endMatrix = Matrix4.identity()
      //translate to distanceToCenter - so it zooms out of the center
      ..translate(distanceToCenter.dx, distanceToCenter.dy)
      ..scale(scale)
      //translate back after zoom is done
      ..translate(-distanceToCenter.dx, -distanceToCenter.dy)
      //translate to the final destination
      ..translate(destination.dx, destination.dy);

    super.startAnimation(endMatrix);
  }

  void scale(double scale) {
    super.endCurrentAnimationIfRunning();

    var endMatrix = transformationController.value.clone();

    var distanceToCenter = _getDistanceToCenter();

    Vector3 currentPosition = _getCurrentTranslation(endMatrix);
    Vector3 currentScale = _getScale(endMatrix);

    Offset origin = Offset(distanceToCenter.dx - currentPosition.x,
        distanceToCenter.dy - currentPosition.y);

    origin /= currentScale.x;

    if (scale != currentScale.x) {
      scaleAndTranslateToPosition(scale, origin);
    }
  }

  Offset _calculateDestinationBasedOnScale(Offset destination, Vector3 scale) {
    // adjust destination to current scale
    var scaledDestination =
        Offset(destination.dx * scale.x, destination.dy * scale.y);

    // adjust the signs cause,
    // the method toScene calculates with negativ coordinates
    scaledDestination *= -1;

    Offset offset = transformationController.toScene(scaledDestination);

    // calculate the distance to center and adjust it to the scale
    var distanceToCenter = _getDistanceToCenter();
    var adjustedDistanceToCenter =
        Offset(distanceToCenter.dx / scale.x, distanceToCenter.dy / scale.y);

    // add distance to center so that the coordinate (0,0) is in the left upper
    // corner
    offset += adjustedDistanceToCenter;
    return offset;
  }

  Offset _getDistanceToCenter() {
    Size childSize = childKey.currentContext?.size ?? Size(0, 0);

    var xToCenter = childSize.width / 2;
    var yToCenter = childSize.height / 2;

    return Offset(xToCenter, yToCenter);
  }

  Vector3 _getScale(endMatrix) {
    var translation = Vector3.zero(),
        rotation = Quaternion.identity(),
        scale = Vector3.zero();

    endMatrix.decompose(translation, rotation, scale);

    return scale;
  }

  Vector3 _getCurrentTranslation(endMatrix) {
    var translation = Vector3.zero(),
        rotation = Quaternion.identity(),
        scale = Vector3.zero();

    endMatrix.decompose(translation, rotation, scale);

    return translation;
  }
}
