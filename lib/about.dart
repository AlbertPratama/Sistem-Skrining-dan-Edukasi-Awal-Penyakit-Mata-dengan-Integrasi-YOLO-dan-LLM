import 'package:flutter/material.dart';
import 'homePage.dart';

class AboutEye extends StatelessWidget {
  const AboutEye({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDEFF9), Color(0xFF5E005E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'About Eye Health',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 4,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _infoCard(
                          icon: Icons.visibility,
                          title: 'Why is Eye Health Important?',
                          content:
                              'More than 2.2 billion people worldwide suffer from visual impairment. In Indonesia, visual impairment is often caused by preventable factors such as cataracts, uveitis, and conjunctivitis.',
                        ),
                        const SizedBox(height: 16),
                        _infoCard(
                          icon: Icons.local_hospital,
                          title: 'Common Eye Diseases',
                          content:
                              '• Cataract: Clouding of the lens of the eye that causes blurred vision.\n'
                              '• Uveitis: Inflammation of the middle layer of the eye that can damage eye tissue.\n'
                              '• Conjunctivitis: Inflammation of the conjunctiva due to infection or allergy.',
                        ),
                        const SizedBox(height: 16),
                        _infoCard(
                          icon: Icons.health_and_safety,
                          title: 'Early Detection and Education',
                          content:
                              'Early detection helps prevent blindness. Educating the public about early symptoms and simple treatments can significantly reduce the number of blindness cases.',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 140,
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const EyeDetection(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xFF5E005E),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Color(0xFF5E005E), size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5E005E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
