import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/song_item.dart';
import '../services/audio_handler_service.dart';
import '../services/youtube_service.dart';

/// Central state manager coordinating YouTube querying and audio playback.
class PlaybackController extends ChangeNotifier {
  final YouTubeService _ytService;
  final AudioHandlerService _audioService;
  StreamSubscription? _playerStateSubscription;

  PlaybackController({
    YouTubeService? ytService,
    AudioHandlerService? audioService,
  })  : _ytService = ytService ?? YouTubeService(),
        _audioService = audioService ?? AudioHandlerService() {
    _playerStateSubscription = _audioService.playerStateStream.listen((_) {
      notifyListeners();
    });
  }

  List<SongItem> _searchResults = [];
  bool _isSearching = false;
  bool _isExtracting = false;
  String? _extractingSongId;
  SongItem? _currentSong;
  String? _errorMessage;

  List<SongItem> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  bool get isExtracting => _isExtracting;
  String? get extractingSongId => _extractingSongId;
  SongItem? get currentSong => _currentSong;
  String? get errorMessage => _errorMessage;
  AudioHandlerService get audioService => _audioService;

  /// Performs a search or parses a direct YouTube URL.
  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    _isSearching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _ytService.searchOrFetch(trimmed);
      _searchResults = results;
      if (results.isEmpty) {
        _errorMessage = 'No videos found for "$query".';
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Extracts the direct audio stream and plays the selected song.
  Future<void> selectAndPlay(SongItem song) async {
    // If the same song is already loaded, toggle playback
    if (_currentSong?.id == song.id && !_isExtracting) {
      await _audioService.togglePlayPause();
      notifyListeners();
      return;
    }

    final targetId = song.id;
    _isExtracting = true;
    _extractingSongId = targetId;
    _errorMessage = null;
    notifyListeners();

    try {
      final audioUri = await _ytService.getAudioStreamUri(targetId);
      // Guard against race conditions if another song was selected in the meantime
      if (_extractingSongId == targetId) {
        _currentSong = song;
        await _audioService.playSong(song, audioUri);
      }
    } catch (e) {
      if (_extractingSongId == targetId) {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      }
    } finally {
      if (_extractingSongId == targetId) {
        _isExtracting = false;
        _extractingSongId = null;
        notifyListeners();
      }
    }
  }

  /// Clears any transient error message.
  void clearError({bool notify = true}) {
    if (_errorMessage != null) {
      _errorMessage = null;
      if (notify) {
        notifyListeners();
      }
    }
  }

  /// Clears current search results.
  void clearResults() {
    _searchResults = [];
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _audioService.dispose();
    _ytService.dispose();
    super.dispose();
  }
}
