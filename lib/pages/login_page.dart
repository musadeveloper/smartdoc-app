import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/services/auth_service.dart'; // Adjust import as needed

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    // Get User from Auth Service
    User? user = await _authService.signInWithEmailPassword(email, password);

    if (user != null) {
      // Navigate to home page
      Navigator.pushReplacementNamed(context, '/home');
    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Image.asset(
                'assets/images/vecteezy_3d-doctor-character-presenting-and-lying-on-big-empty-phone_36485009.png',
                height: 170,
              ),
              SizedBox(height: 16),
              Text(
                'SmartDoc',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5DB8AE),
                ),
              ),
              SizedBox(height: 15),
              // Email Field
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              // Password Field
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 32),
              // Custom Login Button
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFF5DB8AE),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? "),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register'); // Navigate to Register Page
                    },
                    child: Text('Register'),
                    style: TextButton.styleFrom(
                      foregroundColor: Color(0xFF5DB8AE), // Link color
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
