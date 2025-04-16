import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class ConversationListeningPage extends StatefulWidget {
  const ConversationListeningPage({super.key});

  @override
  State<ConversationListeningPage> createState() =>
      _ConversationListeningPageState();
}

class _ConversationListeningPageState extends State<ConversationListeningPage> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    await _player.setSource(AssetSource("audio/conversation_audio.mp3"));
    _player.onDurationChanged.listen((d) => setState(() => _duration = d));
    _player.onPositionChanged.listen((p) => setState(() => _position = p));
    _player.onPlayerComplete.listen(
      (event) => setState(() => _isPlaying = false),
    );
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _player.pause();
    } else {
      _player.resume();
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Widget _glassContainer(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(0, 0, 0, 0.5),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white30),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🎧 Conversation Listening"),
        backgroundColor: const Color.fromRGBO(0, 0, 0, 0.7),
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/bg_home.webp',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _glassContainer(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Learn these Finnish expressions",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '''1. Greeting & Daily Phrases:
                          Moi, Hei, Terve, Moro, Moriesta!
                          Huomenta, iltaa, hyvää yötä, päivää!
                          Kiitos, Kiitti, ole hyvä! nähdään! Tänää Joo, Ei

                          2. Self-Introduction & Interacting:
                          Nimeni on …. oon …. mikä sun nimi? ootko …? hauska tavata! nii! niin! mitä kuuluu? kaikki hyvä! miten menee? hyvin menee! Entä sinä? mistä olet kotoisin? Anteks!

                          3. Powerful Simple Phrases:
                          kiva! Haluatko? voitko? voinko? voi voi! tottakai! missä on …? sopii! Ymmärrätkö? selvä juttu! mul on … mulla ei o … onksul …? Tiedätkö? Hetki … en tiedä! milloin? miks? koska … Ei haitta! on pakko … Ei mitään homma juttu

                          4. Numbers:
                          Yks, kaks, kolme, neljä, viis, kuus, seittemä, kaheksa, yheksä, kymmene
                          Kakskyt, kolkyt, nelkyt, viiskyt, kuuskyt, seiskyt, kaheksankyt, yheksänkyt
                          Kakskytyks, kakskytkaks, kakskytkolme, kakskytkuus, kakskytseittemä, kakskytkahdeksa, kakskytyheksä
                          Paljonko? mitä kello on? Nyt. On ….

                          5. Days of the Week:
                          Maanantai, tiistai, keskiviikko, torstai, perjantai, lauantai, sunnuntai''',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 24),
                    Slider(
                      activeColor: Colors.tealAccent,
                      value: _position.inSeconds.toDouble(),
                      max: _duration.inSeconds.toDouble(),
                      onChanged: (value) {
                        _player.seek(Duration(seconds: value.toInt()));
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            _isPlaying ? Icons.pause_circle : Icons.play_circle,
                            size: 36,
                            color: Colors.white,
                          ),
                          onPressed: _togglePlayPause,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.replay,
                            size: 32,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _player.seek(Duration.zero);
                            if (!_isPlaying) _togglePlayPause();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
