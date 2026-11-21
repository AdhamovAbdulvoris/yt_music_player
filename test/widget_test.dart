import 'package:flutter_test/flutter_test.dart';
import 'package:yt_music_player/models/position_data.dart';
import 'package:yt_music_player/models/song_item.dart';

void main() {
  group('SongItem & PositionData Unit Tests', () {
    test('SongItem formats duration properly', () {
      const song1 = SongItem(
        id: '12345678901',
        title: 'Test Song',
        author: 'Artist',
        duration: Duration(minutes: 3, seconds: 45),
        thumbnailUrl: 'https://img.youtube.com/vi/12345678901/hqdefault.jpg',
      );

      expect(song1.formattedDuration, '03:45');
      expect(song1.youtubeUrl, 'https://www.youtube.com/watch?v=12345678901');

      const songLong = SongItem(
        id: 'long1234567',
        title: 'Long Podcast',
        author: 'Host',
        duration: Duration(hours: 1, minutes: 23, seconds: 45),
        thumbnailUrl: 'https://img.youtube.com/vi/long1234567/hqdefault.jpg',
      );

      expect(songLong.formattedDuration, '1:23:45');

      const songNull = SongItem(
        id: 'null1234567',
        title: 'Live Stream',
        author: 'Streamer',
        duration: null,
        thumbnailUrl: 'https://img.youtube.com/vi/null1234567/hqdefault.jpg',
      );

      expect(songNull.formattedDuration, '--:--');

      // Negative duration edge case
      const songNegative = SongItem(
        id: 'neg12345678',
        title: 'Edge Case Song',
        author: 'Edge Artist',
        duration: Duration(minutes: -2, seconds: -30),
        thumbnailUrl: 'https://img.youtube.com/vi/neg12345678/hqdefault.jpg',
      );

      expect(songNegative.formattedDuration, '02:30');
    });

    test('SongItem equality and hashCode work correctly', () {
      const songA = SongItem(
        id: 'same_id',
        title: 'Title A',
        author: 'Author A',
        thumbnailUrl: 'url_a',
      );
      const songB = SongItem(
        id: 'same_id',
        title: 'Title B',
        author: 'Author B',
        thumbnailUrl: 'url_b',
      );
      const songC = SongItem(
        id: 'other_id',
        title: 'Title A',
        author: 'Author A',
        thumbnailUrl: 'url_a',
      );

      expect(songA, equals(songB));
      expect(songA.hashCode, equals(songB.hashCode));
      expect(songA, isNot(equals(songC)));
    });

    test('PositionData holds audio state accurately', () {
      const data = PositionData(
        position: Duration(seconds: 15),
        bufferedPosition: Duration(seconds: 45),
        duration: Duration(minutes: 3),
      );

      expect(data.position.inSeconds, 15);
      expect(data.bufferedPosition.inSeconds, 45);
      expect(data.duration.inMinutes, 3);

      expect(PositionData.empty.position, Duration.zero);
      expect(PositionData.empty.bufferedPosition, Duration.zero);
      expect(PositionData.empty.duration, Duration.zero);
    });
  });
}
