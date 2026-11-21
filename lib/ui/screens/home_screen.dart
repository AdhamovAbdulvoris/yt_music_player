import 'package:flutter/material.dart';
import '../../controllers/playback_controller.dart';
import '../../models/song_item.dart';
import '../../theme/app_theme.dart';
import '../widgets/mini_player.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/video_list_item.dart';

/// Main home screen allowing users to search YouTube, paste URLs, and browse results.
class HomeScreen extends StatefulWidget {
  final PlaybackController controller;

  const HomeScreen({super.key, required this.controller});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerUpdate);
      widget.controller.addListener(_onControllerUpdate);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    // Show SnackBar safely when an error occurs
    final error = widget.controller.errorMessage;
    if (error != null && mounted) {
      widget.controller.clearError(notify: false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    error,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.primary,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'DISMISS',
              textColor: Colors.white,
              onPressed: () => messenger.hideCurrentSnackBar(),
            ),
          ),
        );
      });
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'YT Background Audio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(68),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchBarWidget(
              isLoading: controller.isSearching,
              onSearch: (query) => controller.search(query),
              onClear: () => controller.clearResults(),
            ),
          ),
        ),
      ),
      body: _buildBody(controller),
      bottomNavigationBar: MiniPlayer(controller: controller),
    );
  }

  Widget _buildBody(PlaybackController controller) {
    if (controller.isSearching) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
            SizedBox(height: 16),
            Text(
              'Searching YouTube...',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (controller.searchResults.isEmpty) {
      return _buildEmptyState(controller);
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: controller.searchResults.length,
      separatorBuilder: (context, index) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final SongItem song = controller.searchResults[index];
        final isCurrent = controller.currentSong?.id == song.id;
        final isExtracting = controller.extractingSongId == song.id;

        return VideoListItem(
          song: song,
          isCurrent: isCurrent,
          isExtracting: isExtracting,
          isPlaying: isCurrent && controller.audioService.isPlaying,
          onTap: () => controller.selectAndPlay(song),
        );
      },
    );
  }

  Widget _buildEmptyState(PlaybackController controller) {
    final sampleQueries = [
      'Lofi hip hop beats',
      'Synthwave radio',
      'Relaxing piano music',
      'Classical chill',
    ];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.divider, width: 1.5),
              ),
              child: const Icon(
                Icons.music_note_rounded,
                size: 38,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Stream YouTube in Background',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Search for any song or channel, or paste a direct YouTube URL above to play audio with the screen locked.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Try searching:',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: sampleQueries.map((query) {
                return ActionChip(
                  label: Text(query),
                  labelStyle: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                  ),
                  backgroundColor: AppTheme.surfaceVariant,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: AppTheme.divider, width: 0.8),
                  ),
                  onPressed: () => controller.search(query),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
