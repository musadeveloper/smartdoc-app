import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer' as devtools;
import '/services/auth_service.dart';
import 'view_diagnosis_page.dart';

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
  String _diagnosisResult = '';
  late Interpreter _interpreter;
  String _userName = '';

  final AuthService _authService = AuthService();

  // Dataset labels
  final List<String> labels = [
    'Acne and Rosacea',
    'Actinic Keratosis Basal Cell Carcinoma and other Malignant Lesions',
    'Atopic Dermatitis',
    'Bullous Disease',
    'Cellulitis Impetigo and other Bacterial Infections',
    'Eczema',
    'Exanthems and Drug Eruptions',
    'Hair Loss Alopecia and other Hair Diseases',
    'Herpes HPV and other STDs',
    'Light Diseases and Disorders of Pigmentation',
    'Lupus and other Connective Tissue diseases',
    'Melanoma Skin Cancer Nevi and Moles',
    'Nail Fungus and other Nail Disease',
    'Poison Ivy and other Contact Dermatitis',
    'Psoriasis Lichen Planus and related diseases',
    'Scabies Lyme Disease and other Infestations and Bites',
    'Seborrheic Keratoses and other Benign Tumors',
    'Systemic Disease',
    'Tinea Ringworm Candidiasis and other Fungal Infections',
    'Urticaria Hives',
    'Vascular Tumors',
    'Vasculitis',
    'Warts Molluscum and other Viral Infections'
  ];

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  // Load the TensorFlow Lite model
  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
    } catch (e) {
      devtools.log('Error loading model: $e');
    }
  }

  // Preprocess image: resize, normalize, and convert to tensor
  Future<List<List<List<List<double>>>>> _preprocessImage(File imageFile) async {
    final image = img.decodeImage(imageFile.readAsBytesSync())!;
    img.Image resized = img.copyResize(image, width: 224, height: 224);

    // Convert image to array of doubles (normalize between 0 and 1)
    List<List<List<List<double>>>> imageTensor = List.generate(
      1,
          (_) => List.generate(224, (y) => List.generate(224, (x) {
        final pixel = resized.getPixel(x, y);
        final r = img.getRed(pixel) / 255.0;
        final g = img.getGreen(pixel) / 255.0;
        final b = img.getBlue(pixel) / 255.0;
        return [r, g, b];
      })),
    );
    return imageTensor;
  }

  Future<void> _getUserName() async {
    try {
      final String email = _authService.getCurrentUserEmail();

      // Getting user data from Firestore using email
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(email).get();

      if (userDoc.exists) {
        setState(() {
          _userName = userDoc['name'] ?? 'Unknown User';
        });
      } else {
        setState(() {
          _userName = 'User not found';
        });
      }
    } catch (e) {
      setState(() {
        _userName = 'Error fetching user data';
      });
    }
  }

  // Pick an image from the camera or gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Image Source'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(ImageSource.camera),
            child: Text('Camera'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
            child: Text('Gallery'),
          ),
        ],
      ),
    );

    if (source != null) {
      final pickedImage = await picker.pickImage(source: source);
      if (pickedImage != null) {
        setState(() {
          _image = File(pickedImage.path);
          _isPhotoSelected = true;
          _isSymptomsSelected = false;
        });
      }
    }
  }

  // Run inference on the selected image
  Future<void> _runInference(File imageFile) async {
    if (imageFile == null) return;

    final imageTensor = await _preprocessImage(imageFile);
    var output = List.filled(1, List.filled(23, 0.0));

    _interpreter.run(imageTensor, output);

    // Get the index of the highest confidence prediction
    final predictedIndex = output[0].indexOf(output[0].reduce((a, b) => a > b ? a : b));

    // Map the index to the label
    final predictedLabel = labels[predictedIndex];

    setState(() {
      _diagnosisResult = "Predicted Condition: $predictedLabel";  // Display the label
    });
  }

  // Submit diagnosis request
  Future<void> _submitDiagnosisRequest() async {
    if (_isPhotoSelected || _isSymptomsSelected) {
      setState(() {
        _isLoading = true;
      });

      if (_isPhotoSelected && _image != null) {
        await _runInference(_image!);
      }

      setState(() {
        _isLoading = false;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Store the diagnosis result in Firestore linked to the user
        await FirebaseFirestore.instance.collection('diagnosis').add({
          'user_id': user.uid,
          'email': user.email,
          'diagnosis_class': _diagnosisResult,
          'timestamp': FieldValue.serverTimestamp()
        });

        // Navigate to the diagnosis page with the result
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewDiagnosisPage(result: _diagnosisResult),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User is not logged in.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select either photo or symptoms option.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = _getUserName();

    return Scaffold(
      appBar: AppBar(
        title: Text('Request a Diagnosis'),
        backgroundColor: Color(0xFF5DB8AE),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          'What\'s wrong, $_userName?',
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
                Text(
                  'Select an option:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      value: _isPhotoSelected,
                      onChanged: (value) {
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
                      onChanged: (value) {
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
                            height: 255,
                            width: 255,
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
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitDiagnosisRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5DB8AE),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Center(
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                      'Submit Diagnosis Request',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  _diagnosisResult,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
