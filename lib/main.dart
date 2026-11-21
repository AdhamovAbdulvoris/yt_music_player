import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'controllers/playback_controller.dart';
import 'theme/app_theme.dart';
import 'ui/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure system overlay style for immersive dark status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize just_audio_background for foreground service and lock-screen controls
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.ytmusic.channel.audio',
    androidNotificationChannelName: 'YouTube Audio Playback',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
    androidNotificationIcon: 'mipmap/ic_launcher',
  );

  final controller = PlaybackController();
  runApp(YouTubeAudioApp(controller: controller));
}

/// Root Application Widget
class YouTubeAudioApp extends StatefulWidget {
  final PlaybackController controller;

  const YouTubeAudioApp({super.key, required this.controller});

  @override
  State<YouTubeAudioApp> createState() => _YouTubeAudioAppState();
}

class _YouTubeAudioAppState extends State<YouTubeAudioApp> {
  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Audio Player',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: HomeScreen(controller: widget.controller),
    );
  }
}
