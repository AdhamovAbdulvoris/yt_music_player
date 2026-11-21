import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../models/song_item.dart';
import '../../theme/app_theme.dart';

/// Clean list item displaying video thumbnail, duration badge, title, and channel.
class VideoListItem extends StatelessWidget {
  final SongItem song;
  final bool isCurrent;
  final bool isExtracting;
  final bool isPlaying;
  final VoidCallback onTap;

  const VideoListItem({
    super.key,
    required this.song,
    required this.isCurrent,
    required this.isExtracting,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isCurrent ? AppTheme.surfaceVariant : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isExtracting ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Thumbnail with duration overlay
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: song.thumbnailUrl,
                      width: 104,
                      height: 62,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 104,
                        height: 62,
                        color: AppTheme.surfaceVariant,
                        child: const Center(
                          child: Icon(Icons.music_note_rounded, color: AppTheme.textSecondary, size: 24),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 104,
                        height: 62,
                        color: AppTheme.surfaceVariant,
                        child: const Center(
                          child: Icon(Icons.broken_image_rounded, color: AppTheme.textSecondary, size: 24),
                        ),
                      ),
                    ),
                    if (song.duration != null)
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            song.formattedDuration,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Title and Channel metadata
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      song.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isCurrent ? AppTheme.primary : AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 13,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            song.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Playback or buffering indicator
              if (isExtracting)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  ),
                )
              else if (isCurrent)
                Icon(
                  isPlaying ? Icons.graphic_eq_rounded : Icons.pause_circle_filled_rounded,
                  color: AppTheme.primary,
                  size: 24,
                )
              else
                const Icon(
                  Icons.play_arrow_rounded,
                  color: AppTheme.textSecondary,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
