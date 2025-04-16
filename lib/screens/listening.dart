import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:neenq/services/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:neenq/widgets/audio/platform_audio_player.dart';

class ListeningPage extends StatefulWidget {
  const ListeningPage({super.key});

  @override
  State<ListeningPage> createState() => _ListeningPageState();
}

class _ListeningPageState extends State<ListeningPage> {
  List<String> questions = [];
  List<TextEditingController> answerControllers = [];
  String? remoteAudioUrl;
  String? localAudioPath;
  bool isLoading = true;
  String? resultScore;
  String? correctAnswers;

  @override
  void initState() {
    super.initState();
    fetchListeningContent();
  }

  Future<void> fetchListeningContent() async {
    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse('$baseUrl/generate_listening_audio'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        questions = List<String>.from(data['questions']);
        remoteAudioUrl = data['audio_path'];

        await downloadAndSaveAudio(remoteAudioUrl!);

        setState(() {
          answerControllers = List.generate(
            questions.length,
            (_) => TextEditingController(),
          );
          isLoading = false;
        });
      } else {
        showError("Failed to load questions and audio.");
      }
    } else {
      showError("Server error while loading listening content.");
    }
  }

  Future<void> downloadAndSaveAudio(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/ielts_listening.mp3');
        await file.writeAsBytes(response.bodyBytes);
        setState(() {
          localAudioPath = file.path;
        });
      } else {
        showError("Failed to download audio.");
      }
    } catch (e) {
      showError("Audio download error: $e");
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    setState(() => isLoading = false);
  }

  Future<void> submitAnswers() async {
    final allAnswered = answerControllers.every(
      (c) => c.text.trim().isNotEmpty,
    );
    if (!allAnswered) {
      showError("⚠️ Please answer all the questions.");
      return;
    }

    final answers = answerControllers.map((c) => c.text.trim()).toList();

    final response = await http.post(
      Uri.parse('$baseUrl/submit_listening'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "answers": answers,
        "questions": questions,
        "audio": remoteAudioUrl ?? "",
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        setState(() {
          resultScore = data['score'];
          correctAnswers = (data['correct_answers'] as List<dynamic>).join(
            "\n",
          );
        });
        showResultDialog(resultScore ?? "Score unknown", correctAnswers);
      } else {
        showError("Scoring failed: ${data['error']}");
      }
    } else {
      showError("Failed to submit answers.");
    }
  }

  void showResultDialog(String score, String? correctAnswers) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("🎷 Listening Result"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your Score:\n\n$score",
                  style: const TextStyle(fontSize: 18),
                ),
                if (correctAnswers != null && correctAnswers.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text(
                    "Correct Answers:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(correctAnswers),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  fetchListeningContent();
                },
                child: const Text("🔄 Try Another"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Close"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🎷 IELTS Listening"),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchListeningContent,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg_listening.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dark overlay
          Container(color: Colors.black.withAlpha(5)),
          // Content
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((kIsWeb && remoteAudioUrl != null) ||
                          (!kIsWeb && localAudioPath != null)) ...[
                        const Text(
                          "🎷 Listen to the audio:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        buildPlatformAudioPlayer(
                          audioUrl: kIsWeb ? remoteAudioUrl! : localAudioPath!,
                          isLocal: !kIsWeb,
                        ),
                        const Divider(height: 30, color: Colors.white),
                      ],
                      const Text(
                        "📜 Questions:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...List.generate(questions.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: TextFormField(
                            controller: answerControllers[index],
                            decoration: InputDecoration(
                              labelText: "${index + 1}. ${questions[index]}",
                              labelStyle: const TextStyle(color: Colors.black),
                              filled: true,
                              fillColor: Colors.white,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: submitAnswers,
                          child: const Text("Submit Answers"),
                        ),
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
