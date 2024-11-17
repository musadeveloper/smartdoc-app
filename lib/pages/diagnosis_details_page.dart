import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DiagnosisDetailsPage extends StatelessWidget {
  final Map<String, dynamic> diagnosisData;

  DiagnosisDetailsPage({required this.diagnosisData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diagnosis Details'),
        backgroundColor: Color(0xFF5DB8AE),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Diagnosis Title
              Center(
                child: Text(
                  diagnosisData['diagnosis_result'] ?? 'Unknown Diagnosis',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5DB8AE),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Definition:',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                diagnosisData['diagnosis_def'] ?? 'Not available',
                style: TextStyle(fontSize: 16.0, color: Colors.black87),
              ),
              SizedBox(height: 20),
              Text(
                'Recommendation:',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                diagnosisData['recommendation'] ?? 'Not available',
                style: TextStyle(fontSize: 16.0, color: Colors.black87),
              ),
              SizedBox(height: 20),
              Text(
                'Severity:',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                diagnosisData['severity'] ?? 'Unknown',
                style: TextStyle(
                  fontSize: 16.0,
                  color: diagnosisData['severity'] == 'Severe'
                      ? Colors.red
                      : (diagnosisData['severity'] == 'Moderate'
                      ? Colors.orange
                      : Colors.green),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),

              // Diagnosis Date
              Text(
                'Date:',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                DateTime.fromMillisecondsSinceEpoch((diagnosisData['date'] as Timestamp).millisecondsSinceEpoch).toLocal().toString(),
                style: TextStyle(fontSize: 16.0, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
