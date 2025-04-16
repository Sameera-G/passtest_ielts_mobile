import 'package:flutter/material.dart';
import 'package:neenq/widgets/audio/platform_audio_player.dart';

class AudioPlayerWidget extends StatelessWidget {
  final String audioUrl;
  final bool isLocal;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    this.isLocal = false,
  });

  @override
  Widget build(BuildContext context) {
    return buildPlatformAudioPlayer(audioUrl: audioUrl, isLocal: isLocal);
  }
}
