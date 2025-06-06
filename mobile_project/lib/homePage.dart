import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'about.dart';
import 'result.dart';

class EyeDetection extends StatefulWidget {
  const EyeDetection({super.key});

  @override
  State<EyeDetection> createState() => _EyeDetectionState();
}

class _EyeDetectionState extends State<EyeDetection> {

  File ? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(200),
        child: Container(
          decoration: BoxDecoration(
            // color: Colors.purple,
            color: Color(0xFF5E005E),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3), // warna bayangan
                offset: Offset(0, 10), // arah bayangan (x, y)
                blurRadius: 10, // seberapa blur bayangannya
                spreadRadius: 1, // seberapa luas area bayangannya
              ),
            ],
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 100.0, top: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.remove_red_eye,
                        color: Colors.white,
                        size: 80,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Eye',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 50,
                        ),
                      ),
                    ],
                  ),
                  // const SizedBox(height: 1),
                  const Text(
                    'Disease Detector',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AboutEye()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5E005E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 10,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'About eye health',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              OutlinedButton(
                onPressed: _pickImageFromCamera,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF5E005E), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.photo_camera, color: Color(0xFF5E005E), size: 50),
                    SizedBox(height: 20),
                    Text(
                      'Take Photo',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              OutlinedButton(
                onPressed: _pickImageFromGallery,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF5E005E), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.upload, color: Color(0xFF5E005E), size: 50),
                    SizedBox(height: 20),
                    Text(
                      'Upload eye image',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future _pickImageFromGallery() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (returnedImage == null) return;

    final imageFile = File(returnedImage.path);

    setState(() {
      _selectedImage = imageFile;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(imageFile: imageFile),
      ),
    );
  }


  Future _pickImageFromCamera() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.camera);

    if (returnedImage == null) return;

    final imageFile = File(returnedImage.path);

    setState(() {
      _selectedImage = imageFile;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(imageFile: imageFile),
      ),
    );
  }

}


