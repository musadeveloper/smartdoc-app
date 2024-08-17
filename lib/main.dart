import 'package:flutter/material.dart';
import 'pages/login_page.dart'; // Adjust import as needed
import 'pages/home_page.dart'; // Adjust import as needed
import 'package:firebase_core/firebase_core.dart';
import 'pages/request_diagnosis_page.dart';
import 'pages/view_diagnosis_page.dart';


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
        '/login': (context) => LoginPage(),
        '/requestDiagnosis': (context) => RequestDiagnosisPage(),
        '/viewDiagnosis': (context) => ViewDiagnosisPage(),
        '/home': (context) => HomePage(), // Optional, for navigation consistency
        //'/profile': (context) => ProfilePage(), // Optional, add your profile page
      },
    );
  }
}