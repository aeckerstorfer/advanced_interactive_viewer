library advanced_interactive_viewer;

import 'package:advanced_interactive_viewer/animations/reset_animation.dart';
import 'package:advanced_interactive_viewer/animations/translate_animation.dart';
import 'package:flutter/material.dart';

class AdvancedInteractiveViewer extends StatefulWidget {
  AdvancedInteractiveViewer({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  _AdvancedInteractiveViewerState createState() =>
      _AdvancedInteractiveViewerState();
}

class _AdvancedInteractiveViewerState extends State<AdvancedInteractiveViewer>
    with TickerProviderStateMixin {
  // Transformation Controller and Animators
  late TransformationController _transformationController;
  late ResetAnimation _resetAnimation;
  late TranslateAnimation _translateAnimation;

  // Global Key to get the Size of the child
  GlobalKey _childKey = GlobalKey();

  //Gets triggered when a user input is detected
  void _onInteractionStart(ScaleStartDetails details) {
    // If the user tries to cause a transformation while the reset animation is
    // running, cancel the reset animation.
    _resetAnimation.cancel();
    _translateAnimation.cancel();
  }

  @override
  void initState() {
    super.initState();

    _transformationController = TransformationController();

    _resetAnimation = ResetAnimation(
      transformationController: _transformationController,
      tickerProvider: this,
      duration: Duration(milliseconds: 400),
    );

    _translateAnimation = TranslateAnimation(
      transformationController: _transformationController,
      tickerProvider: this,
      childKey: _childKey,
      duration: Duration(milliseconds: 400),
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
            child: Container(
              key: _childKey,
              child: widget.child,
            ),
          ),
        ],
      ),
      persistentFooterButtons: [
        IconButton(
          onPressed: _resetAnimation.start,
          icon: Icon(Icons.replay),
        ),
        IconButton(
          onPressed: _translateAnimation.start,
          icon: Icon(Icons.arrow_right),
        ),
        IconButton(
          onPressed: () => _translateAnimation.translate(Offset(300, 600)),
          icon: Icon(Icons.car_rental),
        ),
        IconButton(
          onPressed: () => _translateAnimation.scaleAndTranslateToPosition(
              0.5, Offset(300, 600)),
          icon: Icon(Icons.zoom_out),
        ),
        IconButton(
          onPressed: () => _translateAnimation.scale(0.5),
          icon: Icon(Icons.zoom_out),
        ),
      ],
    );
  }
}
