import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:neenq/services/constants.dart'; // Make sure this defines `baseUrl`

class ReadingPage extends StatefulWidget {
  const ReadingPage({super.key});

  @override
  State<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  String passage = "";
  List<String> questions = List.filled(6, "[Loading question...]");
  List<TextEditingController> controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  String? resultScore;
  List<String> correctAnswers = List.filled(6, "");
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchReadingContent();
  }

  Future<void> fetchReadingContent() async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(Uri.parse('$baseUrl/generate_content'));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['content'] != null) {
          final content = data['content'] as String;
          final lines =
              content
                  .split(RegExp(r'\n+'))
                  .map((line) => line.trim())
                  .where((line) => line.isNotEmpty)
                  .toList();

          List<String> passageLines = [];
          List<String> extractedQuestions = [];

          for (var line in lines) {
            if (RegExp(r'^\d+\.\s').hasMatch(line)) {
              extractedQuestions.add(
                line.replaceFirst(RegExp(r'^\d+\.\s+'), '').trim(),
              );
            } else {
              passageLines.add(line);
            }
          }

          setState(() {
            passage = passageLines.join("\n\n");
            for (int i = 0; i < 6; i++) {
              questions[i] =
                  i < extractedQuestions.length
                      ? extractedQuestions[i]
                      : "[Question missing]";
              controllers[i].text = "";
            }
          });
        } else {
          _showError("Invalid content received from backend.");
        }
      } else {
        _showError("Failed to load content. Try again.");
      }
    } catch (e) {
      _showError("Error fetching data: $e");
    }

    if (mounted) setState(() => isLoading = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> submitAnswers() async {
    bool allFilled = controllers.every((c) => c.text.trim().isNotEmpty);
    if (!allFilled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please answer all the questions.")),
      );
      return;
    }

    setState(() => isLoading = true);

    final answers = controllers.map((c) => c.text.trim()).toList();
    final questionsText = questions.map((q) => "Q: $q").toList();

    final response = await http.post(
      Uri.parse('$baseUrl/submit_answers'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "answers": answers,
        "questions": questionsText,
        "passage": passage,
      }),
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        final score = data['score'];
        final feedback = data['feedback'];
        final correct = List<String>.from(data['correct_answers'] ?? []);

        setState(() {
          resultScore = score;
          correctAnswers = correct;
        });

        showResultDialog(score, feedback, correct);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Scoring failed: ${data['error']}")),
        );
      }
    }
  }

  void showResultDialog(String score, String feedback, List<String> correct) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("📊 Test Result"),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Your Score: $score"),
                  const SizedBox(height: 10),
                  Text("Feedback: $feedback"),
                  const SizedBox(height: 16),
                  const Text(
                    "✅ Correct Answers:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(correct.length, (i) {
                    return Text("Q${i + 1}: ${correct[i]}");
                  }),
                  const SizedBox(height: 20),
                  const Text("Would you like to try another?"),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  fetchReadingContent();
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
        title: const Text("📘 IELTS Reading"),
        backgroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchReadingContent,
            tooltip: "Generate New Content",
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg_reading.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withAlpha(6)),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "📖 Reading Passage",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SelectableText(
                          passage,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "📝 Questions",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 6,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: TextFormField(
                              controller: controllers[index],
                              decoration: InputDecoration(
                                labelText: "Q${index + 1}: ${questions[index]}",
                                labelStyle: const TextStyle(
                                  color: Colors.black,
                                ), // ✅ set to black
                                filled: true,
                                fillColor: Colors.white,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          );
                        },
                      ),
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
