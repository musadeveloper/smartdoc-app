import 'package:flutter/material.dart';
import '/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RequestDiagnosisPage extends StatefulWidget {
  final AuthService _authService = AuthService();

  @override
  _RequestDiagnosisPageState createState() => _RequestDiagnosisPageState();
}

class _RequestDiagnosisPageState extends State<RequestDiagnosisPage> {
  File? _image;
  bool _isPhotoSelected = false;
  bool _isSymptomsSelected = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path); // Store the image file
      });
    }
  }

  void _submitDiagnosisRequest() {
    if (_isPhotoSelected || _isSymptomsSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Diagnosis request submitted successfully.'),
        ),
      );
      // Add your submission logic here.
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select either photo or symptoms option.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String userEmail = widget._authService.getCurrentUserEmail();

    return Scaffold(
      appBar: AppBar(
        title: Text('Request a Diagnosis'),
        backgroundColor: Color(0xFF5DB8AE),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Added Container for Information Box
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
                      _isSymptomsSelected = false; // Deselect other option
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
                      _isPhotoSelected = false; // Deselect other option
                    });
                  },
                ),
                Text('Describe Your Symptoms'),
              ],
            ),
            SizedBox(height: 20),

            // Show icon when photo option is selected
            if (_isPhotoSelected)
              Center(
                child: Column(
                  children: [
                    IconButton(
                      iconSize: 100.0,
                      icon: Icon(Icons.photo_camera, color: Color(0xFF5DB8AE)),
                      onPressed: _pickImage, // Use the pick image function
                    ),
                    Text(
                      'Take/Upload a Photo',
                      style: TextStyle(fontSize: 18, color: Color(0xFF5DB8AE)),
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
            Spacer(),
            ElevatedButton(
              onPressed: _submitDiagnosisRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5DB8AE), // Updated color property
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
