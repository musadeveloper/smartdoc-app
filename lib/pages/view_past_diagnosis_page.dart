import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/auth_service.dart';
import 'diagnosis_details_page.dart'; // Import your AuthService class

class ViewPastDiagnosesPage extends StatelessWidget {
  final AuthService authService = AuthService(); // Create an instance of AuthService

  @override
  Widget build(BuildContext context) {
    // Get the user's email from AuthService
    final String userEmail = authService.getCurrentUserEmail();

    return Scaffold(
      appBar: AppBar(
        title: Text('Past Diagnosis'),
        backgroundColor: Color(0xFF5DB8AE),
      ),
      body: userEmail == 'Guest'
          ? Center(
        child: Text(
          'No user is logged in.',
          style: TextStyle(fontSize: 16.0, color: Colors.grey),
        ),
      )
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('diagnosis_report')
            .where('email', isEqualTo: userEmail) // Filter by userEmail
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading past diagnoses.'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No past diagnoses found.',
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
            );
          } else {
            final diagnoses = snapshot.data!.docs;

            return ListView.builder(
              itemCount: diagnoses.length,
              itemBuilder: (context, index) {
                final diagnosis = diagnoses[index];
                final diagnosisData = diagnosis.data() as Map<String, dynamic>;

                return ListTile(
                  leading: Icon(
                    Icons.medical_services_outlined,
                    color: Color(0xFF5DB8AE),
                  ),
                  title: Text(
                    diagnosisData['diagnosis_result'] ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5DB8AE),
                    ),
                  ),
                  subtitle: Text(
                    'Date: ${DateTime.fromMillisecondsSinceEpoch((diagnosisData['date'] as Timestamp).millisecondsSinceEpoch).toLocal()}',
                    style: TextStyle(fontSize: 14.0, color: Colors.grey),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  onTap: () {
                    // Navigate to details page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DiagnosisDetailsPage(
                          diagnosisData: diagnosisData,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
