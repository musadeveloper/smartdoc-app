import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'view_diagnosis_page.dart';
import '/services/auth_service.dart';

class RequestDiagnosisPage extends StatefulWidget {
  final AuthService _authService = AuthService();
  @override
  _RequestDiagnosisPageState createState() => _RequestDiagnosisPageState();
}

class _RequestDiagnosisPageState extends State<RequestDiagnosisPage> {
  File? _image;
  bool _isPhotoSelected = false;
  bool _isSymptomsSelected = false;
  bool _isLoading = false;
  List<String>? _labels;

  final AuthService _authService = AuthService();
  late Interpreter _interpreter;

  @override
  void initState() {
    super.initState();
    _loadModel();
    _loadLabels();
  }

  // Load the TFLite model
  Future<void> _loadModel() async {
    _interpreter = await Interpreter.fromAsset('model.tflite');
  }

  // Load labels from the labels.txt file
  Future<void> _loadLabels() async {
    final labelFile = await rootBundle.loadString('assets/labels.txt');
    _labels = labelFile.split('\n');
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
        _isPhotoSelected = true;
        _isSymptomsSelected = false;
      });
    }
  }

  Future<void> _submitDiagnosisRequest() async {
    if (_isPhotoSelected || _isSymptomsSelected) {
      setState(() {
        _isLoading = true;
      });

      String diagnosisResult = 'No result';

      if (_isPhotoSelected && _image != null) {
        try {
          // Preprocess the image
          var input = await _processImage(_image!);

          // Run inference
          var output = List.filled(_labels!.length, 0.0).reshape([1, _labels!.length]);
          _interpreter.run(input, output);

          // Get the predicted label
          int predictedIndex = output[0].indexOf(output[0].reduce((a, b) => a > b ? a : b));
          diagnosisResult = _labels![predictedIndex];
        } catch (e) {
          diagnosisResult = 'Error during inference: $e';
        }
      }

      setState(() {
        _isLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewDiagnosisPage(result: diagnosisResult),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select either photo or symptoms option.'),
        ),
      );
    }
  }

  // Process image for the TFLite model
  Future<List<List<List<double>>>> _processImage(File imageFile) async {
    final rawImage = File(imageFile.path).readAsBytesSync();
    final decodedImage = img.decodeImage(rawImage);

    if (decodedImage == null) throw 'Error decoding image';

    // Resize the image to 224x224 for the model
    final resizedImage = img.copyResize(decodedImage, width: 224, height: 224);

    // Normalize the image (convert pixels to float values)
    List<List<List<double>>> normalizedImage = List.generate(
      224,
          (y) => List.generate(
        224,
            (x) => [
          resizedImage.getPixel(x, y).r / 255.0,
          resizedImage.getPixel(x, y).g / 255.0,
          resizedImage.getPixel(x, y).b / 255.0,
        ],
      ),
    );

    return normalizedImage;
  }

  @override
  Widget build(BuildContext context) {
    final String userEmail = _authService.getCurrentUserEmail(); // Example user email

    return Scaffold(
      appBar: AppBar(
        title: Text('Request a Diagnosis'),
        backgroundColor: Color(0xFF5DB8AE),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Information Box
            Container(
              margin: EdgeInsets.all(16.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'What\'s wrong, $userEmail?',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  Image.asset(
                    'assets/images/vecteezy_3d-doctor-character-confused-and-thinking-pose-suitable-for_36485048.png',
                    height: 150,
                  ),
                ],
              ),
            ),

            // Diagnosis Options
            Text(
              'Select an option:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: _isPhotoSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      _isPhotoSelected = value!;
                      _isSymptomsSelected = false;
                    });
                  },
                ),
                Text('Take/Upload a Photo'),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: _isSymptomsSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      _isSymptomsSelected = value!;
                      _isPhotoSelected = false;
                    });
                  },
                ),
                Text('Describe Your Symptoms'),
              ],
            ),
            SizedBox(height: 20),

            // Show camera icon if photo option is selected
            if (_isPhotoSelected)
              Center(
                child: Column(
                  children: [
                    if (_image == null)
                      IconButton(
                        icon: Icon(Icons.camera_alt, size: 100, color: Colors.grey),
                        onPressed: _pickImage,
                      ),
                    if (_image != null)
                      Image.file(
                        _image!,
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                  ],
                ),
              ),

            if (_isSymptomsSelected)
              TextField(
                decoration: InputDecoration(
                  labelText: 'Describe your symptoms here...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            SizedBox(height: 20),

            // Show loading indicator if processing
            if (_isLoading)
              Center(child: CircularProgressIndicator()),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitDiagnosisRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5DB8AE),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: Center(
                child: Text(
                  'Submit Request',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
