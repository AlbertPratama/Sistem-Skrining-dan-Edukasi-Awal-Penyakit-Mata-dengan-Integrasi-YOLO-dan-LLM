import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mobile_project/homePage.dart';

class ResultDetail extends StatefulWidget {
  final String resultClass;
  final double confidence;

  const ResultDetail({
    Key? key,
    required this.resultClass,
    required this.confidence,
  }) : super(key: key);

  @override
  State<ResultDetail> createState() => _ResultDetailState();
}

class _ResultDetailState extends State<ResultDetail> {
  String? explanation;
  bool isLoading = true;
  bool hasError = false;
  bool showChatInput = false;
  String chatbotResponse = "";
  bool isChatLoading = false;
  final TextEditingController _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchLLMExplanation();
  }

  Future<void> fetchLLMExplanation() async {
    final uri = Uri.parse('http://192.168.78.168:5000/explain');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'resultClass': widget.resultClass,
          'confidence': widget.confidence,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          explanation = data['explanation'];
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> sendChatQuestion() async {
    setState(() {
      chatbotResponse = "";
      isChatLoading = true;
    });

    final request = http.Request(
      'POST',
      Uri.parse("http://192.168.78.168:5000/chat"),
    );

    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode({
      "question": _chatController.text,
      "resultClass": widget.resultClass,
      "confidence": widget.confidence,
    });

    try {
      final response = await http.Client().send(request);

      response.stream
          .transform(utf8.decoder)
          .listen(
            (value) {
              setState(() {
                chatbotResponse += value;
              });
            },
            onDone: () {
              setState(() {
                isChatLoading = false;
              });
            },
            onError: (e) {
              setState(() {
                chatbotResponse = "❌ Terjadi kesalahan.";
                isChatLoading = false;
              });
            },
          );
    } catch (e) {
      setState(() {
        chatbotResponse = "❌ Gagal terhubung ke server.";
        isChatLoading = false;
      });
    }
  }

  List<TextSpan> buildExplanationSpans(String text) {
    final boldWords = [
      "Low Confidence",
      "Balanced Prediction",
      "High Confidence",
    ];
    final spans = <TextSpan>[];

    text.splitMapJoin(
      RegExp(r'(Low Confidence|Balanced Prediction|High Confidence)'),
      onMatch: (match) {
        spans.add(
          TextSpan(
            text: match.group(0),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
        return '';
      },
      onNonMatch: (nonMatch) {
        spans.add(TextSpan(text: nonMatch));
        return '';
      },
    );

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBEFF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5E005E),
        iconTheme: IconThemeData(
          color: Colors.white, // Ubah warna di sini
        ),
        title: const Text(
          "Eye Result Explanation",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "🧠 Your Eye Screening Result",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5E005E),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  "AI-Based Early Screening",
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🔍 Result: ${widget.resultClass}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '🎯 Confidence: ${(widget.confidence * 100).toStringAsFixed(2)}%',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "🧾 Explanation Using LLM:",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5E005E),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2DCF2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child:
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : hasError
                        ? const Text(
                          "❌ Failed to load explanation. Please try again.",
                          style: TextStyle(color: Colors.red),
                        )
                        : RichText(
                          text: TextSpan(
                            children: buildExplanationSpans(explanation ?? ""),
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                        ),
              ),
              const SizedBox(height: 30),
              const Text(
                "🤖 Apakah Anda memiliki pertanyaan lain seputar hasil deteksi penyakit mata Anda?",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              if (!showChatInput)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() => showChatInput = true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF5E005E),
                      ),
                      child: const Text(
                        "Tanyakan pada AI",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      child: const Text(
                        "Back to Home",
                        style: TextStyle(color: Color(0xFF5E005E)),
                      ),
                    ),
                  ],
                ),
              if (showChatInput) ...[
                const SizedBox(height: 20),
                TextField(
                  controller: _chatController,
                  decoration: const InputDecoration(
                    hintText: "Ketik pertanyaan Anda...",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: isChatLoading ? null : sendChatQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF5E005E),
                      ),
                      child: const Text(
                        "Kirim Pertanyaan",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (chatbotResponse.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _chatController.clear();
                            chatbotResponse = "";
                          });
                        },
                        child: const Text("Clear Chat"),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (isChatLoading)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                if (chatbotResponse.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      chatbotResponse,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                const SizedBox(height: 60),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
