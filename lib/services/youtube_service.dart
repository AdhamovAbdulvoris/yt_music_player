import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/song_item.dart';

/// Service responsible for communicating with YouTube via [YoutubeExplode].
/// Handles video searches, URL parsing, and audio stream extraction.
class YouTubeService {
  final YoutubeExplode _yt = YoutubeExplode();

  /// Searches YouTube or extracts a video directly if [query] is a URL or ID.
  Future<List<SongItem>> searchOrFetch(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return [];

    // Try parsing as a direct YouTube Video URL or Video ID
    try {
      final videoId = VideoId(trimmedQuery);
      final video = await _yt.videos.get(videoId);
      return [SongItem.fromVideo(video)];
    } catch (_) {
      // Query is not a direct URL/ID; continue to standard search
    }

    try {
      final searchResults = await _yt.search.search(trimmedQuery);
      return searchResults.map(SongItem.fromVideo).toList();
    } catch (e) {
      throw Exception('Failed to search YouTube: ${e.toString()}');
    }
  }

  /// Extracts the direct audio stream URI with the highest available bitrate.
  Future<Uri> getAudioStreamUri(String videoId) async {
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final audioStreams = manifest.audioOnly;

      if (audioStreams.isNotEmpty) {
        // Pick the stream with the highest bitrate (e.g. 160kbps Opus / AAC)
        final highestAudioStream = audioStreams.withHighestBitrate();
        return highestAudioStream.url;
      }

      // Fallback: check muxed streams if audio-only streams are not provided
      final muxedStreams = manifest.muxed;
      if (muxedStreams.isNotEmpty) {
        final highestMuxedStream = muxedStreams.withHighestBitrate();
        return highestMuxedStream.url;
      }

      throw Exception('No playable audio stream available for this video.');
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      throw Exception('Unable to extract audio stream: $msg');
    }
  }

  /// Closes the underlying HTTP clients and resources.
  void dispose() {
    _yt.close();
  }
}
