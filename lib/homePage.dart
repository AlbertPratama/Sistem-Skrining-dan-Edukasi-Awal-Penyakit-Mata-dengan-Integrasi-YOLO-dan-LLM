import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'about.dart';
import 'result.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';

class EyeDetection extends StatefulWidget {
  const EyeDetection({super.key});

  @override
  State<EyeDetection> createState() => _EyeDetectionState();
}

class _EyeDetectionState extends State<EyeDetection> {
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(200),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF5E005E),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 10),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
            borderRadius: const BorderRadius.only(
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
                    children: const [
                      Icon(Icons.remove_red_eye, color: Colors.white, size: 80),
                      SizedBox(width: 12),
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
                  const Text(
                    'Disease Detector',
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
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
                backgroundColor: const Color(0xFF5E005E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 10,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'About Eye Health',
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
                    style: TextStyle(color: Colors.black, fontSize: 20),
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
                    'Upload Eye Image',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final returnedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      if (returnedImage == null) return;

      final imageFile = File(returnedImage.path);

      setState(() {
        _selectedImage = imageFile;
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.78.168:5000/predict'),
      );
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
      print('Image File: $imageFile');
      print("====");
      print(imageFile.path);

      final response = await request.send();

      Navigator.of(context).pop(); // Close loading

      if (response.statusCode == 200) {
        print("✅ Response OK from server");

        final contentType = response.headers['content-type'];
        print("📦 Content-Type: $contentType");

        if (contentType != null && contentType.contains('application/json')) {
          final respStr = await response.stream.bytesToString();
          print("📨 Response Body: $respStr");

          final decoded = json.decode(respStr);
          final detection =
              decoded['detections'].isNotEmpty
                  ? decoded['detections'][0]
                  : null;

          String? disease = detection?['class'];
          double? confidence = detection?['confidence'];
          String? imageUrl = decoded['image_path']; // ✅ FIXED KEY

          print("🧪 Deteksi: $disease");
          print("🎯 Confidence: $confidence");
          print("🖼️ Image URL: $imageUrl");

          if (imageUrl == null) {
            throw Exception("Image URL from backend is null");
          }

          final imageUrlWithTimestamp =
              "$imageUrl?ts=${DateTime.now().millisecondsSinceEpoch}";

          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ResultPage(
                    imageUrl: imageUrlWithTimestamp,
                    resultClass: disease ?? "Unknown",
                    confidence: confidence ?? 0.0,
                  ),
            ),
          );
        } else {
          throw Exception("Unexpected content type or no JSON returned.");
        }
      } else {
        print("❌ Response from server: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memproses gambar di server')),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      print("Error saat upload gambar: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat upload gambar')),
      );
    }
  }

  Future<void> _pickImageFromCamera() async {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Panduan Pengambilan Foto'),
          content: const Text(
            'Pastikan mengarahkan kamera ke area mata dan terlihat jelas, tanpa bayangan, pantulan, atau cahaya berlebih. Ambil gambar pada pencahayaan yang cukup.',
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Oke'),
              onPressed: () async {
                Navigator.of(context).pop(); // Tutup dialog

                Future.delayed(const Duration(milliseconds: 300), () {
                  _handleTakePhoto(); // Panggil fungsi terpisah untuk kamera
                });

                // Tampilkan modal konfirmasi setelah ambil gambar
                // if (!mounted) return; // tambahkan untuk keamanan context
                // await showModalBottomSheet(
                //   context: context,
                //   builder: (BuildContext bottomSheetContext) {
                //     return SafeArea(
                //       child: Column(
                //         mainAxisSize: MainAxisSize.min,
                //         children: [
                //           const Padding(
                //             padding: EdgeInsets.all(16.0),
                //             child: Text(
                //               'Apakah foto ini sudah sesuai?',
                //               style: TextStyle(fontSize: 18),
                //             ),
                //           ),
                //           Image.file(imageFile, height: 200),
                //           Row(
                //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //             children: [
                //               TextButton(
                //                 child: const Text("Ambil Ulang"),
                //                 onPressed:
                //                     () => Navigator.pop(bottomSheetContext),
                //               ),
                //               ElevatedButton.icon(
                //                 icon: const Icon(Icons.check),
                //                 label: const Text("Gunakan Foto Ini"),
                //                 onPressed: () {
                //                   Navigator.pop(
                //                     bottomSheetContext,
                //                   ); // tutup modal
                //                   _processImage(imageFile); // kirim ke backend
                //                 },
                //               ),
                //             ],
                //           ),
                //           const SizedBox(height: 20),
                //         ],
                //       ),
                //     );
                //   },
                // );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleTakePhoto() async {
    try {
      final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.camera,
      );

      print('PICKE TELAH BERHASIL!');
      print("Hasil : $pickedImage");

      if (pickedImage == null) return;

      final imageFile = File(pickedImage.path);
      print("Hasil : $imageFile");

      setState(() {
        _selectedImage = imageFile;
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      //
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.78.168:5000/predict'),
      );
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final response = await request.send();

      Navigator.of(context).pop(); // Close loading

      if (response.statusCode == 200) {
        print("✅ Response OK from server");
        final contentType = response.headers['content-type'];
        print("📦 Content-Type: $contentType");
        if (contentType != null && contentType.contains('application/json')) {
          final respStr = await response.stream.bytesToString();
          final decoded = json.decode(respStr);
          final detection =
              decoded['detections'].isNotEmpty
                  ? decoded['detections'][0]
                  : null;

          String? disease = detection?['class'];
          double? confidence = detection?['confidence'];
          String? imageUrl = decoded['image_path'];

          if (imageUrl == null) {
            throw Exception("Image URL from backend is null");
          }

          final imageUrlWithTimestamp =
              "$imageUrl?ts=${DateTime.now().millisecondsSinceEpoch}";

          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ResultPage(
                    imageUrl: imageUrlWithTimestamp,
                    resultClass: disease ?? "Unknown",
                    confidence: confidence ?? 0.0,
                  ),
            ),
          );
        } else {
          throw Exception("Unexpected content type or no JSON returned.");
        }
      } else {
        print("❌ Response from server: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memproses gambar di server')),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Tutup dialog kalau error
      print("Error saat upload gambar: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat upload gambar')),
      );
    }
  }

  // Future<void> _processImage(File imageFile) async {
  //   print("📍 Current context: $context");
  //   try {
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (_) => const Center(child: CircularProgressIndicator()),
  //     );

  //     var request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse('http://192.168.78.168:5000/predict'),
  //     );
  //     request.files.add(
  //       await http.MultipartFile.fromPath('image', imageFile.path),
  //     );

  //     final response = await request.send();
  //     Navigator.of(context).pop(); // close loading

  //     if (response.statusCode == 200) {
  //       final contentType = response.headers['content-type'];
  //       if (contentType != null && contentType.contains('application/json')) {
  //         final respStr = await response.stream.bytesToString();
  //         final decoded = json.decode(respStr);
  //         final detection =
  //             decoded['detections'].isNotEmpty
  //                 ? decoded['detections'][0]
  //                 : null;

  //         String? disease = detection?['class'];
  //         double? confidence = detection?['confidence'];
  //         String? imageUrl = decoded['image_path'];

  //         if (imageUrl == null) throw Exception("Image URL is null");

  //         final imageUrlWithTimestamp =
  //             "$imageUrl?ts=${DateTime.now().millisecondsSinceEpoch}";

  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder:
  //                 (context) => ResultPage(
  //                   imageUrl: imageUrlWithTimestamp,
  //                   resultClass: disease ?? "Unknown",
  //                   confidence: confidence ?? 0.0,
  //                 ),
  //           ),
  //         );
  //       } else {
  //         throw Exception("Unexpected content type");
  //       }
  //     } else {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(const SnackBar(content: Text('Gagal memproses gambar')));
  //     }
  //   } catch (e) {
  //     Navigator.of(context).pop();
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
  //   }
  // }
}
