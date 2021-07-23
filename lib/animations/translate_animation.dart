import 'package:advanced_interactive_viewer/animations/base_animation.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

class TranslateAnimation extends BaseAnimation {
  GlobalKey childKey;

  TranslateAnimation({
    required transformationController,
    required tickerProvider,
    required this.childKey,
    duration = const Duration(milliseconds: 400),
  }) : super(transformationController, tickerProvider, duration);

  List<Offset> positions = [
    Offset(0, 100),
    Offset(-100, 0),
    Offset(0, -100),
    Offset(100, 0),
  ];

  int index = 0;

  void start() {
    index++;
    Offset pos = positions[index % 4];
    Matrix4 endMatrix = transformationController.value.clone();
    endMatrix.translate(pos.dx.toDouble(), pos.dy.toDouble());

    super.startAnimation(endMatrix);
  }

  void translateToScene(Offset targetOffset) {
    Matrix4 endMatrix = transformationController.value.clone();

    var translation = Vector3.zero(),
        rotation = Quaternion.identity(),
        scale = Vector3.zero();
    endMatrix.decompose(translation, rotation, scale);

    Offset offset = transformationController.toScene(targetOffset * scale.x);

    var distanceToCenter = _getDistanceToCenter();
    offset += (distanceToCenter / scale.x);
    endMatrix.translate(offset.dx, offset.dy);
    print('Scale X: ' + scale.x.toString());
    print('Translation: ' + translation.toString());
    print('Offset: ' + offset.toString());
    print('Offset times scaleX' + (offset * scale.x).toString());
    print('Distance to Center' + distanceToCenter.toString());
    super.startAnimation(endMatrix);
  }

  void translate(Offset targetOffset) {
    Matrix4 endMatrix = transformationController.value.clone();
    Offset currentPosition = _getCurrentPosition(endMatrix);

    Offset deltaOffset = targetOffset - currentPosition;

    deltaOffset += _getDistanceToCenter();

    deltaOffset += _calculateSizeDifference(endMatrix);

    endMatrix.translate(deltaOffset.dx, deltaOffset.dy);

    print(deltaOffset);

    super.startAnimation(endMatrix);
  }

  Offset _getDistanceToCenter() {
    Size childSize = childKey.currentContext?.size ?? Size(0, 0);

    var xToCenter = childSize.width / 2;
    var yToCenter = childSize.height / 2;

    return Offset(xToCenter, yToCenter);
  }

  Offset _getCurrentPosition(Matrix4 endMatrix) {
    Vector3 currentTranslation = endMatrix.getTranslation();
    return Offset(currentTranslation.x, currentTranslation.y);
  }

  Offset _calculateSizeDifference(Matrix4 endMatrix) {
    var translation = Vector3.zero(),
        rotation = Quaternion.identity(),
        scale = Vector3.zero();
    endMatrix.decompose(translation, rotation, scale);

    Size size = this.childKey.currentContext?.size ?? Size(0, 0);

    var width = size.width;
    var height = size.height;

    var width_diff = (width - (width * scale.x)) / 2;
    var height_diff = (height - (height * scale.y)) / 2;

    return Offset(width_diff, height_diff);
  }
}
