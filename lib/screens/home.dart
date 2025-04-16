import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:neenq/screens/listening.dart';
import 'package:neenq/screens/reading.dart';
import 'package:neenq/screens/writing.dart';
import 'package:neenq/services/constants.dart';
import 'login.dart';

class Home extends StatefulWidget {
  final String firstName;
  const Home({super.key, required this.firstName});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playWelcomeAudio();
  }

  Future<void> _playWelcomeAudio() async {
    final response = await http.post(
      Uri.parse('$baseUrl/generate-audio'),
      headers: {'Content-Type': 'application/json'},
      body: '{"firstName": "${widget.firstName}"}',
    );

    if (response.statusCode == 200) {
      await _player.play(BytesSource(response.bodyBytes));
    } else {
      debugPrint("Failed to load audio");
    }
  }

  Future<void> _logout() async {
    await _player.stop();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  Widget _ieltsCard({
    required String icon,
    required String title,
    required String desc,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(13),
              border: Border.all(color: Colors.white10),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(icon, style: TextStyle(fontSize: 32, color: color)),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withAlpha(13),
        title: Row(
          children: const [
            CircleAvatar(
              backgroundColor: Colors.indigo,
              radius: 16,
              child: Text("IE", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(width: 10),
            Text("IELTS Practice"),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Stack(
        children: [
          // Gradient background animation simulation
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bg_home.webp"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "Master Your IELTS Exam",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      foreground:
                          Paint()
                            ..shader = LinearGradient(
                              colors: [Colors.indigo, Colors.teal],
                            ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _ieltsCard(
                        icon: "📖",
                        title: "Reading",
                        desc: "Practice comprehension with real passages.",
                        color: const Color(0xFF6EE7B7),
                        onTap: () {
                          //Navigate to Reading
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ReadingPage(),
                            ),
                          );
                        },
                      ),
                      _ieltsCard(
                        icon: "🎧",
                        title: "Listening",
                        desc: "Sharpen your listening with practice audio.",
                        color: const Color(0xFF93C5FD),
                        onTap: () {
                          //Navigate to Listening
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ListeningPage(),
                            ),
                          );
                        },
                      ),
                      _ieltsCard(
                        icon: "✍️",
                        title: "Writing",
                        desc: "Task 1 and 2 guided practice.",
                        color: const Color(0xFFF9A8D4),
                        onTap: () {
                          //Navigate to Writing
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WritingPage(),
                            ),
                          );
                        },
                      ),
                      _ieltsCard(
                        icon: "🗣️",
                        title: "Speaking",
                        desc: "Answer topics with feedback.",
                        color: const Color(0xFFFCD34D),
                        onTap: () {
                          // TODO: Navigate to Speaking
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Understand the path to mastering IELTS",
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
