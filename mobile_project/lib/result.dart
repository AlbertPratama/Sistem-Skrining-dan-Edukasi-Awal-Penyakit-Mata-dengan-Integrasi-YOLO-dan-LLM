import 'dart:io';
import 'package:flutter/material.dart';

import 'resultDetail.dart';

class ResultPage extends StatelessWidget {
  final File imageFile;

  const ResultPage({Key? key, required this.imageFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAD3E2),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF5E005E),
            ),
          ),
        ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              Image.file(imageFile, height: 400),
              const SizedBox(height: 20),
              const Text(
                'Result : Uveitis',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5E005E),
                ),
              ),
              const Text(
                'Confidence : 0.74',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5E005E),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'To learn more about your eye screening results, please click the button below.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ResultDetail()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5E005E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 10,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: Size(150, 20),
                ),
                child: const Text(
                  'Press me',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
