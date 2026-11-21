import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../controllers/playback_controller.dart';
import '../../models/position_data.dart';
import '../../theme/app_theme.dart';
import '../screens/player_screen.dart';

/// Persistent bottom mini player widget showing current track info and playback toggle.
class MiniPlayer extends StatelessWidget {
  final PlaybackController controller;

  const MiniPlayer({super.key, required this.controller});

  void _openFullPlayer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlayerScreen(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final song = controller.currentSong;
    if (song == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: const Border(
          top: BorderSide(color: AppTheme.divider, width: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thin progress indicator along the top edge of the mini player
            StreamBuilder<PositionData>(
              stream: controller.audioService.positionDataStream,
              builder: (context, snapshot) {
                final data = snapshot.data ?? PositionData.empty;
                final durationMs = data.duration.inMilliseconds;
                final positionMs = data.position.inMilliseconds;
                final progress = (durationMs > 0)
                    ? (positionMs / durationMs).clamp(0.0, 1.0)
                    : 0.0;

                return LinearProgressIndicator(
                  value: progress,
                  minHeight: 2.5,
                  backgroundColor: AppTheme.divider,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                );
              },
            ),
            // Track details and action buttons
            InkWell(
              onTap: () => _openFullPlayer(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Artwork Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: song.thumbnailUrl,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 48,
                          height: 48,
                          color: AppTheme.surfaceVariant,
                          child: const Icon(Icons.music_note_rounded, size: 20, color: AppTheme.textSecondary),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 48,
                          height: 48,
                          color: AppTheme.surfaceVariant,
                          child: const Icon(Icons.broken_image_rounded, size: 20, color: AppTheme.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title & Artist
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            song.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Skip 10s back
                    IconButton(
                      icon: const Icon(Icons.replay_10_rounded, size: 24, color: AppTheme.textPrimary),
                      tooltip: 'Back 10s',
                      onPressed: () => controller.audioService.skipBackward(),
                    ),
                    // Play / Pause Stream Button
                    StreamBuilder<PlayerState>(
                      stream: controller.audioService.playerStateStream,
                      builder: (context, snapshot) {
                        final playerState = snapshot.data;
                        final processingState = playerState?.processingState;
                        final isPlaying = playerState?.playing ?? false;

                        if (processingState == ProcessingState.loading ||
                            processingState == ProcessingState.buffering) {
                          return const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                              ),
                            ),
                          );
                        }

                        return IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            size: 30,
                            color: AppTheme.primary,
                          ),
                          onPressed: () => controller.audioService.togglePlayPause(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
