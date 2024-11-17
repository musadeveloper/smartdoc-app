import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<Map<String, String>> fetchDiseaseDetails(String diseaseName) async {

  // API Key linked to my ChatGPT Account
  const String apiKey = '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'; // Replace with your actual OpenAI API key.

  final Uri url = Uri.parse('https://api.openai.com/v1/completions');
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
  };

  // Data sent to ChatGPT
  final data = {
    "model": "gpt-3.5-turbo",
    "messages": [
      {"role": "system", "content": "You are a helpful medical assistant."},
      {
        "role": "user",
        "content": "Please provide a definition, recommendation and severity(Low or Moderate or Severe) for the disease: $diseaseName."
      }
    ],
    "temperature": 0.7,
    "max_tokens": 200,
  };

  // Call to ChatGPT API
  try {
    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String result = responseData['choices']?[0]?['message']?['content'] ?? "";

      String definition = "Not specified";
      String recommendation = "Not specified";
      String severity = "Not specified";

      // Extract definition from response
      final definitionRegex = RegExp(r"(?<=Definition:\s)(.*?)(?=Recommendation:|$)", dotAll: true);
      final definitionMatch = definitionRegex.firstMatch(result);
      if (definitionMatch != null) {
        definition = definitionMatch.group(0)?.trim() ?? "Not specified";
      }

      // Extract recommendation from response
      final recommendationRegex = RegExp(r"(?<=Recommendation:\s)(.*?)(?=Severity:|$)", dotAll: true);
      final recommendationMatch = recommendationRegex.firstMatch(result);
      if (recommendationMatch != null) {
        recommendation = recommendationMatch.group(0)?.trim() ?? "Not specified";
      }

      // Extract severity from response
      final severityRegex = RegExp(r'\b(Low|Moderate|Severe)\b', caseSensitive: false);
      final severityMatch = severityRegex.firstMatch(result);
      if (severityMatch != null) {
        severity = severityMatch.group(0)?.trim() ?? "Not specified";
      }

      return {
        'definition': definition,
        'recommendation': recommendation,
        'severity': severity,
      };
    } else {
      return {
        'definition': 'Failed to load definition',
        'recommendation': 'Not specified',
        'severity': 'Not specified',
      };
    }
  } catch (e) {
    return {
      'definition': 'Error: ${e.toString()}',
      'recommendation': 'Not specified',
      'severity': 'Not specified',
    };
  }
}

class ViewDiagnosisPage extends StatefulWidget {
  final String result;

  ViewDiagnosisPage({required this.result});

  @override
  _ViewDiagnosisPageState createState() => _ViewDiagnosisPageState();
}

class _ViewDiagnosisPageState extends State<ViewDiagnosisPage> {
  late Future<Map<String, String>> diseaseDetails;

  @override
  void initState() {
    super.initState();
    diseaseDetails = fetchDiseaseDetails(widget.result);
  }

  // Save Diagnosis to Firebase Database
  Future<void> saveDiagnosisToFirebase(
      String diagnosis,
      String definition,
      String recommendation,
      String severity,
      ) async {
    try {
      String? userEmail = FirebaseAuth.instance.currentUser?.email ?? 'Anonymous';
      Timestamp timestamp = Timestamp.now();

      await FirebaseFirestore.instance.collection('diagnosis_report').add({
        'date': timestamp,
        'diagnosis_result': diagnosis,
        'diagnosis_def': definition,
        'email': userEmail,
        'recommendation': recommendation,
        'severity': severity,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Diagnosis saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving diagnosis: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Diagnosis'),
        backgroundColor: Color(0xFF5DB8AE),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.all(16.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Diagnosis Result:',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5DB8AE),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    widget.result,
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            FutureBuilder<Map<String, String>>(
              future: diseaseDetails,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!['definition']!.isEmpty) {
                  return Center(child: Text('No additional information available.'));
                } else {
                  return Center(
                    child: Container(
                      margin: EdgeInsets.all(16.0),
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Disease Definition:',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5DB8AE),
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            snapshot.data!['definition']!,
                            style: TextStyle(fontSize: 16.0, color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Recommendation:',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5DB8AE),
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            snapshot.data!['recommendation']!,
                            style: TextStyle(fontSize: 16.0, color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Severity:',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5DB8AE),
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            snapshot.data!['severity']!,
                            style: TextStyle(fontSize: 16.0, color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  diseaseDetails.then((details) {
                    saveDiagnosisToFirebase(
                      widget.result,
                      details['definition']!,
                      details['recommendation']!,
                      details['severity']!,
                    );
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5DB8AE),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text(
                  'Save Diagnosis',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5DB8AE),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text(
                  'Go Back',
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
