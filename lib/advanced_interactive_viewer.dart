library advanced_interactive_viewer;

import 'package:advanced_interactive_viewer/animations/reset_animation.dart';
import 'package:advanced_interactive_viewer/animations/translate_animation.dart';
import 'package:advanced_interactive_viewer/static_values/animation_duration.dart';
import 'package:flutter/material.dart';

class AdvancedInteractiveViewer extends StatefulWidget {
  AdvancedInteractiveViewer({
    Key? key,
    required this.child,
    this.showFooter = false,
    this.animationSpeed = AnimationSpeed.MEDIUM,
    this.minScale = 0.1,
    this.maxScale = 10,
    this.onInteractionStart,
  }) : super(key: key);

  final Widget child;
  final bool showFooter;
  final AnimationSpeed animationSpeed;
  final double minScale;
  final double maxScale;
  final Function(ScaleStartDetails details)? onInteractionStart;

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

  //Animation Speed
  late AnimationSpeed animationSpeed;

  //Gets triggered when a user input is detected
  void _onInteractionStart(ScaleStartDetails details) {
    // If the user tries to cause a transformation while the reset animation is
    // running, cancel the reset animation.
    _resetAnimation.cancel();
    _translateAnimation.cancel();

    if (widget.onInteractionStart != null) widget.onInteractionStart!(details);
  }

  @override
  void initState() {
    super.initState();

    animationSpeed = widget.animationSpeed;

    _transformationController = TransformationController();

    _resetAnimation = ResetAnimation(
      transformationController: _transformationController,
      tickerProvider: this,
      animationSpeed: animationSpeed,
    );

    _translateAnimation = TranslateAnimation(
      transformationController: _transformationController,
      tickerProvider: this,
      childKey: _childKey,
      animationSpeed: animationSpeed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          InteractiveViewer(
            transformationController: _transformationController,
            onInteractionStart: _onInteractionStart,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            minScale: widget.minScale,
            maxScale: widget.maxScale,
            child: Container(
              key: _childKey,
              child: widget.child,
            ),
          ),
        ],
      ),
      persistentFooterButtons: widget.showFooter ? _getFooter() : null,
    );
  }

  String _capitalizeString(String text) =>
      text[0].toUpperCase() + text.substring(1).toLowerCase();

  void updateAnimationSpeed(AnimationSpeed? newValue) {
    setState(() {
      animationSpeed = newValue!;

      _resetAnimation.changeAnimationSpeed(animationSpeed);
      _translateAnimation.changeAnimationSpeed(animationSpeed);
    });
  }

  List<Widget> _getFooter() {
    return [
      DropdownButton<AnimationSpeed>(
        value: animationSpeed,
        onChanged: updateAnimationSpeed,
        items: AnimationSpeed.values.map((AnimationSpeed animationSpeed) {
          return DropdownMenuItem<AnimationSpeed>(
            value: animationSpeed,
            child: Text(
              _capitalizeString(animationSpeed.toString().split('.')[1]),
            ),
          );
        }).toList(),
      ),
      IconButton(
        onPressed: _resetAnimation.start,
        icon: Icon(Icons.replay),
      ),
    ];
  }
}
