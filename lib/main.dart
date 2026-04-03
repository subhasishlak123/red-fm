import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the background service
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.radio.channel.audio',
    androidNotificationChannelName: 'Radio Playback',
    androidNotificationOngoing: true,
  );
  
  runApp(const MaterialApp(home: RadioPlayerScreen()));
}

class RadioPlayerScreen extends StatefulWidget {
  const RadioPlayerScreen({super.key});

  @override
  State<RadioPlayerScreen> createState() => _RadioPlayerScreenState();
}

class _RadioPlayerScreenState extends State<RadioPlayerScreen> {
  final _player = AudioPlayer();
  final String streamUrl = "https://funasia.streamguys1.com/live9";

  @override
  void initState() {
    super.initState();
    _loadRadio();
  }

  Future<void> _loadRadio() async {
    try {
      // metadata shows up on your lock screen
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(streamUrl),
          tag: const MediaItem(
            id: '1',
            title: "FunAsia Live",
            album: "Live Stream",
            artUri: null, 
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose(); // Cleans up memory when app is closed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(title: const Text("FunAsia Radio"), backgroundColor: Colors.transparent),
      body: Center(
        child: StreamBuilder<PlayerState>(
          stream: _player.playerStateStream,
          builder: (context, snapshot) {
            final playing = snapshot.data?.playing ?? false;
            final processingState = snapshot.data?.processingState;

            if (processingState == ProcessingState.loading) {
              return const CircularProgressIndicator(color: Colors.white);
            }
            return IconButton(
              iconSize: 100,
              color: Colors.white,
              icon: Icon(playing ? Icons.pause_circle : Icons.play_circle),
              onPressed: playing ? _player.pause : _player.play,
            );
          },
        ),
      ),
    );
  }
}
