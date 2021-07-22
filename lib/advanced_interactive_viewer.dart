library advanced_interactive_viewer;

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class AdvancedInteractiveViewer extends StatefulWidget {
  AdvancedInteractiveViewer({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  _AdvancedInteractiveViewerState createState() =>
      _AdvancedInteractiveViewerState();
}

class _AdvancedInteractiveViewerState extends State<AdvancedInteractiveViewer>
    with TickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();

  GlobalKey _key = GlobalKey();
  // #############################################################
  //
  // #############################################################

  Animation<Matrix4>? _animationReset;
  late final AnimationController _controllerReset;

  void _onAnimateReset() {
    _transformationController.value = _animationReset!.value;
    if (!_controllerReset.isAnimating) {
      _animationReset!.removeListener(_onAnimateReset);
      _animationReset = null;
      _controllerReset.reset();
    }
  }

  void _animateResetInitialize() {
    _controllerReset.reset();
    _animationReset = Matrix4Tween(
      begin: _transformationController.value,
      end: Matrix4.identity(),
    ).animate(_controllerReset);
    _animationReset!.addListener(_onAnimateReset);
    _controllerReset.forward();
  }

  void _animateResetStop() {
    _controllerReset.stop();
    _animationReset?.removeListener(_onAnimateReset);
    _animationReset = null;
    _controllerReset.reset();
  }

  // #############################################################
  //
  // #############################################################

  Animation<Matrix4>? _animationMove;
  late final AnimationController _controllerMove;

  void _onAnimateMove() {
    _transformationController.value = _animationMove!.value;
    if (!_controllerMove.isAnimating) {
      _animationMove!.removeListener(_onAnimateMove);
      _animationMove = null;
      _controllerMove.reset();
    }
  }

  List<Offset> positions = [
    Offset(0, 0),
    Offset(0, 100),
    Offset(-100, 0),
    Offset(0, -100),
    Offset(100, 0),
  ];

  int index = 0;

  void _animateMoveInitialize() {
    index++;
    Offset pos = positions[index % 5];
    Matrix4 endMatrix = _transformationController.value.clone();

    endMatrix.translate(pos.dx.toDouble(), pos.dy.toDouble());

    // Size size = _key.currentContext?.size ?? Size(0, 0);

    // // ---------------------------------------------------------
    // endMatrix.setEntry(
    //     0,
    //     3,
    //     pos.dx * endMatrix.entry(0, 0) +
    //         (endMatrix.entry(0, 0) * size.width - size.width) / 2);
    // // vm.Vector4 row0 = endMatrix.getRow(0);
    // // row0.w = pos.dx * row0.x;
    // // endMatrix.setRow(0, row0);
    // // ---------------------------------------------------------
    // endMatrix.setEntry(
    //     1,
    //     3,
    //     pos.dy * endMatrix.entry(1, 1) +
    //         (endMatrix.entry(1, 1) * size.height - size.height) / 2);
    // // vm.Vector4 row1 = endMatrix.getRow(1);
    // // row1.w = pos.dy * row1.y;
    // // endMatrix.setRow(1, row1);
    // // ---------------------------------------------------------

    print(_key.currentContext?.size);
    print(endMatrix);

    _controllerMove.reset();
    _animationMove = Matrix4Tween(
      begin: _transformationController.value,
      end: endMatrix,
    ).animate(_controllerMove);
    _animationMove!.addListener(_onAnimateMove);
    _controllerMove.forward();
  }

  void _animateMoveStop() {
    _controllerMove.stop();
    _animationMove?.removeListener(_onAnimateMove);
    _animationMove = null;
    _controllerMove.reset();
  }

  // #############################################################
  //
  // #############################################################

  void _onInteractionStart(ScaleStartDetails details) {
    // If the user tries to cause a transformation while the reset animation is
    // running, cancel the reset animation.
    if (_controllerReset.status == AnimationStatus.forward) {
      _animateResetStop();
      _animateMoveStop();
    }
  }

  @override
  void initState() {
    super.initState();
    _controllerReset = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _controllerMove = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(child: Icon(Icons.add)),
          InteractiveViewer(
            transformationController: _transformationController,
            onInteractionStart: _onInteractionStart,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            minScale: 0.1,
            maxScale: 10,
            child: widget.child,
          ),
        ],
      ),
      persistentFooterButtons: [
        IconButton(
          onPressed: _animateResetInitialize,
          icon: Icon(Icons.replay),
        ),
        IconButton(
          onPressed: _animateMoveInitialize,
          icon: Icon(Icons.arrow_right),
        ),
      ],
    );
  }
}
