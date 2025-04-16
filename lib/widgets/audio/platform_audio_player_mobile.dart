import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class _NativeAudioPlayer extends StatefulWidget {
  final String audioUrl;
  final bool isLocal;

  const _NativeAudioPlayer({required this.audioUrl, required this.isLocal});

  @override
  State<_NativeAudioPlayer> createState() => _NativeAudioPlayerState();
}

class _NativeAudioPlayerState extends State<_NativeAudioPlayer> {
  late AudioPlayer _player;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      if (widget.isLocal) {
        await _player.setFilePath(widget.audioUrl);
      } else {
        await _player.setUrl(widget.audioUrl);
      }
    } catch (e) {
      setState(() => isError = true);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isError) {
      return const Text("❌ Audio load error");
    }
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: () => _player.play(),
        ),
        IconButton(
          icon: const Icon(Icons.pause),
          onPressed: () => _player.pause(),
        ),
        IconButton(
          icon: const Icon(Icons.stop),
          onPressed: () => _player.stop(),
        ),
      ],
    );
  }
}

Widget buildPlatformAudioPlayer({
  required String audioUrl,
  required bool isLocal,
}) {
  return _NativeAudioPlayer(audioUrl: audioUrl, isLocal: isLocal);
}
