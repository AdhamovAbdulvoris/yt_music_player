import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Represents a YouTube video/audio track with essential playback and display metadata.
class SongItem {
  final String id;
  final String title;
  final String author;
  final Duration? duration;
  final String thumbnailUrl;

  const SongItem({
    required this.id,
    required this.title,
    required this.author,
    this.duration,
    required this.thumbnailUrl,
  });

  /// Factory constructor to map from a [Video] object returned by `youtube_explode_dart`.
  factory SongItem.fromVideo(Video video) {
    // High-res (hqdefault 480x360) is reliably available for all YouTube videos without 404s
    final thumbUrl = video.thumbnails.highResUrl.isNotEmpty
        ? video.thumbnails.highResUrl
        : (video.thumbnails.mediumResUrl.isNotEmpty
            ? video.thumbnails.mediumResUrl
            : (video.thumbnails.maxResUrl.isNotEmpty
                ? video.thumbnails.maxResUrl
                : video.thumbnails.standardResUrl));

    return SongItem(
      id: video.id.value,
      title: video.title,
      author: video.author,
      duration: video.duration,
      thumbnailUrl: thumbUrl,
    );
  }

  /// Direct YouTube watch URL.
  String get youtubeUrl => 'https://www.youtube.com/watch?v=$id';

  /// Human-readable duration string (e.g. "04:12" or "01:23:45").
  String get formattedDuration {
    if (duration == null) return '--:--';
    final dur = duration!.abs();
    final hours = dur.inHours;
    final minutes = dur.inMinutes.remainder(60);
    final seconds = dur.inSeconds.remainder(60);

    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      return '$hours:$minutesStr:$secondsStr';
    } else {
      return '$minutesStr:$secondsStr';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
