import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';
import '../models/position_data.dart';
import '../models/song_item.dart';

/// Service responsible for managing [AudioPlayer], background audio playback,
/// audio session configuration, and progress streams.
class AudioHandlerService {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<void>? _noisySubscription;

  AudioHandlerService() {
    _initAudioSession();
  }

  /// Configures the device audio session for background music playback.
  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Automatically pause when headphones are unplugged
    _noisySubscription = session.becomingNoisyEventStream.listen((_) {
      pause();
    });
  }

  /// AudioPlayer instance getter.
  AudioPlayer get player => _player;

  /// Stream of PlayerState (playing state & processing state).
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  /// Combined stream emitting position, buffered position, and total duration.
  Stream<PositionData> get positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _player.positionStream,
        _player.bufferedPositionStream,
        _player.durationStream,
        (position, bufferedPosition, duration) => PositionData(
          position: position,
          bufferedPosition: bufferedPosition,
          duration: duration ?? Duration.zero,
        ),
      );

  /// Whether audio is currently playing.
  bool get isPlaying => _player.playing;

  /// Loads and plays a song using the direct [audioUri] with background notification metadata.
  Future<void> playSong(SongItem song, Uri audioUri) async {
    try {
      final audioSource = AudioSource.uri(
        audioUri,
        tag: MediaItem(
          id: song.id,
          album: 'YouTube Background Audio',
          title: song.title,
          artist: song.author,
          artUri: Uri.tryParse(song.thumbnailUrl),
          duration: song.duration,
        ),
      );

      await _player.setAudioSource(audioSource);
      await _player.play();
    } catch (e) {
      throw Exception('Audio player error: ${e.toString()}');
    }
  }

  /// Resumes playback.
  Future<void> play() async {
    if (_player.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero);
    }
    await _player.play();
  }

  /// Pauses playback.
  Future<void> pause() => _player.pause();

  /// Toggles between play and pause.
  Future<void> togglePlayPause() async {
    if (_player.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero);
      await _player.play();
      return;
    }
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  /// Seeks to a specific duration position.
  Future<void> seek(Duration position) => _player.seek(position);

  /// Skips forward by [duration] (default 10 seconds).
  Future<void> skipForward([Duration duration = const Duration(seconds: 10)]) async {
    final currentPos = _player.position;
    final totalDuration = _player.duration;
    final targetPos = currentPos + duration;

    if (totalDuration != null && totalDuration > Duration.zero && targetPos > totalDuration) {
      await _player.seek(totalDuration);
    } else {
      await _player.seek(targetPos);
    }
  }

  /// Skips backward by [duration] (default 10 seconds).
  Future<void> skipBackward([Duration duration = const Duration(seconds: 10)]) async {
    final currentPos = _player.position;
    final targetPos = currentPos - duration;

    if (targetPos < Duration.zero) {
      await _player.seek(Duration.zero);
    } else {
      await _player.seek(targetPos);
    }
  }

  /// Stops audio playback.
  Future<void> stop() => _player.stop();

  /// Disposes audio player resources.
  Future<void> dispose() async {
    await _noisySubscription?.cancel();
    await _player.dispose();
  }
}
