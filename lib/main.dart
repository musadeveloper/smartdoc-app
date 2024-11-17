import 'package:flutter/material.dart';
import 'pages/login_page.dart'; // Adjust import as needed
import 'pages/register_page.dart';
import 'pages/home_page.dart'; // Adjust import as needed
import 'package:firebase_core/firebase_core.dart';
import 'pages/request_diagnosis_page.dart';
import 'pages/view_diagnosis_page.dart';
import 'pages/view_past_diagnosis_page.dart';
import 'pages/diagnosis_details_page.dart';
import 'pages/profile_page.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartDoc',
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/register': (context) => RegisterPage(),
        '/login': (context) => LoginPage(),
        '/requestDiagnosis': (context) => RequestDiagnosisPage(),
        '/viewDiagnosis': (context) => ViewDiagnosisPage(result: ''),
        '/home': (context) => HomePage(),
        '/profile': (context) => ProfilePage(),
        '/viewPastDiagnosis': (context) => ViewPastDiagnosesPage(),
        '/diagnosisDetails': (context) => DiagnosisDetailsPage(diagnosisData: {},),// Optional, for navigation consistency
        //'/profile': (context) => ProfilePage(), // Optional, add your profile page
      },
    );
  }
}