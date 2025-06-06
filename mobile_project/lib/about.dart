import 'package:flutter/material.dart';
import 'homePage.dart';

class AboutEye extends StatelessWidget {
  const AboutEye({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAD3E2),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF5E005E),
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(50),
            ),
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              width: 500.0,
              height: 50.0,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white70),
              ),
              child: const Text(
                textAlign: TextAlign.center,
                'About Eye Health',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5E005E),
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 2,
                      color: Colors.black38,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            Expanded(
              child: SingleChildScrollView(
                child: const Text(
                  '''Eye health is one of the vital aspects of human life. According to the WHO, more than 2.2 billion people worldwide suffer from vision impairment. In Indonesia, based on data from the Ministry of Health, cataracts remain one of the leading causes of blindness. Two other common eye diseases are uveitis and conjunctivitis. Early detection and eye health education are crucial to prevent further complications. However, challenges such as a shortage of medical specialists, lack of public awareness, and limited access to healthcare services remain significant obstacles, especially in remote areas.''',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 100,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => EyeDetection()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5E005E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
