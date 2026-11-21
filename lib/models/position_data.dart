/// Model combining audio position, buffered position, and total duration.
class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  const PositionData({
    required this.position,
    required this.bufferedPosition,
    required this.duration,
  });

  static const empty = PositionData(
    position: Duration.zero,
    bufferedPosition: Duration.zero,
    duration: Duration.zero,
  );
}
