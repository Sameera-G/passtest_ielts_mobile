import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:neenq/services/constants.dart';

class WritingPage extends StatefulWidget {
  const WritingPage({super.key});

  @override
  State<WritingPage> createState() => _WritingPageState();
}

class _WritingPageState extends State<WritingPage> {
  String? task1;
  String? task2;
  final answer1Controller = TextEditingController();
  final answer2Controller = TextEditingController();
  bool isLoading = true;
  String? resultScore;
  String? analysis;

  @override
  void initState() {
    super.initState();
    loadWritingQuestions();
  }

  Future<void> loadWritingQuestions() async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/generate_writing_questions'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            task1 = data['task1'] ?? 'Task 1 not loaded.';
            task2 = data['task2'] ?? 'Task 2 not loaded.';
            answer1Controller.clear();
            answer2Controller.clear();
            isLoading = false;
          });
        } else {
          showError("Failed to load writing tasks.");
        }
      } else {
        showError("Server error while fetching writing questions.");
      }
    } catch (e) {
      showError("Network error: $e");
    }
  }

  Future<void> submitWritingAnswers() async {
    FocusScope.of(context).unfocus(); // hide keyboard

    final a1 = answer1Controller.text.trim();
    final a2 = answer2Controller.text.trim();

    if (a1.isEmpty || a2.isEmpty) {
      showError("Please answer both tasks before submitting.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/submit_writing'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "task1": task1,
          "task2": task2,
          "answer1": a1,
          "answer2": a2,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          final score = data['score'] ?? "Unknown";
          final analysisText = data['analysis'] ?? "No feedback.";
          setState(() {
            resultScore = score;
            analysis = analysisText;
          });
          showResultDialog(score, analysisText);
        } else {
          showError("Scoring failed: ${data['error']}");
        }
      } else {
        showError("Server error while submitting answers.");
      }
    } catch (e) {
      showError("Network error: $e");
    }
  }

  void showResultDialog(String score, String feedback) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("📊 Writing Evaluation"),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Score:",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(score, style: const TextStyle(fontSize: 18)),
                  const Divider(height: 20),
                  const Text(
                    "Feedback:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(feedback, textAlign: TextAlign.justify),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  loadWritingQuestions();
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

  void showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📝 IELTS Writing"),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadWritingQuestions,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg_writing.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Dark overlay
          Opacity(opacity: 0.4, child: Container(color: Colors.black)),

          // Content
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "📘 Task 1: Letter Writing",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        task1 ?? "Loading...",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: answer1Controller,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          hintText: "Write your Task 1 answer here...",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "📙 Task 2: Essay Writing",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        task2 ?? "Loading...",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: answer2Controller,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          hintText: "Write your Task 2 essay here...",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: submitWritingAnswers,
                          icon: const Icon(Icons.check),
                          label: const Text("Submit Answers"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
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
