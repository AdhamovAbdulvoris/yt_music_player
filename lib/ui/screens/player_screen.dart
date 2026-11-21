import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../controllers/playback_controller.dart';
import '../../models/position_data.dart';
import '../../theme/app_theme.dart';

/// Full-screen modal player sheet displaying high-resolution artwork,
/// audio progress bar with buffered indicator, and playback controls.
class PlayerScreen extends StatelessWidget {
  final PlaybackController controller;

  const PlayerScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final song = controller.currentSong;
        if (song == null) {
          return const SizedBox.shrink();
        }

        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top drag handle & minimize bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 30),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Text(
                        'NOW PLAYING',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(width: 48), // Balance header row
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Large Artwork with shadow
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: song.thumbnailUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppTheme.surfaceVariant,
                            child: const Center(
                              child: Icon(Icons.music_note_rounded, color: AppTheme.textSecondary, size: 48),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppTheme.surfaceVariant,
                            child: const Center(
                              child: Icon(Icons.broken_image_rounded, color: AppTheme.textSecondary, size: 48),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title and Artist
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      song.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      song.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Progress Bar Stream
                  StreamBuilder<PositionData>(
                    stream: controller.audioService.positionDataStream,
                    builder: (context, snapshot) {
                      final positionData = snapshot.data ?? PositionData.empty;
                      final totalDuration = positionData.duration;
                      final currentPosition = (totalDuration > Duration.zero && positionData.position > totalDuration)
                          ? totalDuration
                          : positionData.position;
                      final currentBuffered = (totalDuration > Duration.zero && positionData.bufferedPosition > totalDuration)
                          ? totalDuration
                          : positionData.bufferedPosition;

                      return ProgressBar(
                        progress: currentPosition,
                        buffered: currentBuffered,
                        total: totalDuration,
                        progressBarColor: AppTheme.primary,
                        baseBarColor: AppTheme.divider,
                        bufferedBarColor: AppTheme.divider.withValues(alpha: 0.8),
                        thumbColor: Colors.white,
                        thumbRadius: 7.0,
                        thumbGlowRadius: 18.0,
                        barHeight: 4.0,
                        timeLabelTextStyle: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        onSeek: (duration) {
                          controller.audioService.seek(duration);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Controls: Replay 10s, Play/Pause, Forward 10s
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Skip backward 10s
                      IconButton(
                        iconSize: 38,
                        tooltip: 'Back 10 seconds',
                        icon: const Icon(
                          Icons.replay_10_rounded,
                          color: AppTheme.textPrimary,
                        ),
                        onPressed: () => controller.audioService.skipBackward(),
                      ),

                      // Main Play / Pause button
                      StreamBuilder<PlayerState>(
                        stream: controller.audioService.playerStateStream,
                        builder: (context, snapshot) {
                          final playerState = snapshot.data;
                          final processingState = playerState?.processingState;
                          final isPlaying = playerState?.playing ?? false;

                          if (processingState == ProcessingState.loading ||
                              processingState == ProcessingState.buffering) {
                            return Container(
                              width: 64,
                              height: 64,
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            );
                          }

                          return Material(
                            color: AppTheme.primary,
                            shape: const CircleBorder(),
                            elevation: 6,
                            shadowColor: AppTheme.primary.withValues(alpha: 0.4),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => controller.audioService.togglePlayPause(),
                              child: Container(
                                width: 64,
                                height: 64,
                                alignment: Alignment.center,
                                child: Icon(
                                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  size: 38,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // Skip forward 10s
                      IconButton(
                        iconSize: 38,
                        tooltip: 'Forward 10 seconds',
                        icon: const Icon(
                          Icons.forward_10_rounded,
                          color: AppTheme.textPrimary,
                        ),
                        onPressed: () => controller.audioService.skipForward(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Background Playback Notice Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.divider, width: 0.8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.headphones_rounded, size: 16, color: AppTheme.primary),
                        SizedBox(width: 8),
                        Text(
                          'Background & Lock Screen Playback Active',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
