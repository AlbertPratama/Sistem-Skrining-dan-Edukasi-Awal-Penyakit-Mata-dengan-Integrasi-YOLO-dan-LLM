import 'package:flutter/material.dart';
import 'package:mobile_project/resultDetail.dart';

class ResultPage extends StatelessWidget {
  final String imageUrl;
  final String resultClass;
  final double confidence;

  const ResultPage({
    Key? key,
    required this.imageUrl,
    required this.resultClass,
    required this.confidence,
  }) : super(key: key);

  String getConfidenceHeading(double value) {
    if (value < 0.4) return "🔍 Low Confidence";
    if (value >= 0.4 && value <= 0.7) return "✅ Correct Prediction";
    return "🟢 High Confidence";
  }

  String getConfidenceMessage(double value) {
    if (value < 0.4) {
      return "The model tries to capture the results well, but the possibility of errors is quite high. Try again with a clearer image.";
    } else if (value >= 0.4 && value <= 0.7) {
      return "The model believes these results are correct based on the evaluation of the metrics used in this study, but it is still advisable to consult a professional if symptoms persist.";
    } else {
      return "The model is very confident with this result. If the disease is detected, it is likely accurate. However, still check with a doctor if there are further complaints.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAD3E2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5E005E),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          "Eye Screening Result",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        elevation: 4,
        shadowColor: Colors.black45,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // Tampilan gambar dengan padding dan radius
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder:
                    (_, __, ___) => const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "❌ Failed to load image",
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 24),

            // Result class
            Text(
              'Result: $resultClass',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5E005E),
              ),
            ),

            // Confidence
            Text(
              'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 20, color: Colors.black87),
            ),
            const SizedBox(height: 24),

            // Confidence Message Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(2, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getConfidenceHeading(confidence),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5E005E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    getConfidenceMessage(confidence),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            const Text(
              'To learn more about your eye screening results, please click the button below.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            // Button Learn More
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ResultDetail(
                          resultClass: resultClass,
                          confidence: confidence,
                        ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5E005E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'Learn More with LLM',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
