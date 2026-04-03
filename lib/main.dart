import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

void main() async {
  // Initialize background capabilities
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  runApp(const RadioApp());
}

class RadioApp extends StatelessWidget {
  const RadioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RadioScreen(),
    );
  }
}

class RadioScreen extends StatefulWidget {
  @override
  _RadioScreenState createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> {
  final _player = AudioPlayer();
  final String streamUrl = "https://funasia.streamguys1.com/live9";

  @override
  void initState() {
    super.initState();
    _setupAudio();
  }

  void _setupAudio() async {
    // Define the audio source with metadata for the lock screen
    final source = AudioSource.uri(
      Uri.parse(streamUrl),
      tag: MediaItem(
        id: '1',
        album: "Live Radio",
        title: "FunAsia Stream",
        artUri: Uri.parse("https://via.placeholder.com/300"), // Optional logo
      ),
    );

    try {
      await _player.setAudioSource(source);
    } catch (e) {
      print("Error loading stream: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Radio App")),
      body: Center(
        child: StreamBuilder<PlayerState>(
          stream: _player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;

            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return CircularProgressIndicator();
            } else if (playing != true) {
              return IconButton(
                icon: Icon(Icons.play_arrow),
                iconSize: 64,
                onPressed: _player.play,
              );
            } else {
              return IconButton(
                icon: Icon(Icons.pause),
                iconSize: 64,
                onPressed: _player.pause,
              );
            }
          },
        ),
      ),
    );
  }
}
