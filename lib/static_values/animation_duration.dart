enum AnimationSpeed {
  FAST,
  MEDIUM,
  SLOW,
  NONE,
}

extension AnimationSpeedExtension on AnimationSpeed {
  Duration getDuration() {
    switch (this) {
      case AnimationSpeed.FAST:
        return Duration(milliseconds: 200);
      case AnimationSpeed.MEDIUM:
        return Duration(milliseconds: 400);
      case AnimationSpeed.SLOW:
        return Duration(milliseconds: 800);
      case AnimationSpeed.NONE:
        return Duration(milliseconds: 0);
      default:
        return AnimationSpeed.MEDIUM.getDuration();
    }
  }
}
