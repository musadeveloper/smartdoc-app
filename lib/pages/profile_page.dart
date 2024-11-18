import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/services/auth_service.dart'; // Adjust import as needed
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore import

class ProfilePage extends StatelessWidget {
  final AuthService _authService = AuthService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Get current user details from Firestore
  Future<Map<String, String>> _getUserDetails() async {
    final String email = _authService.getCurrentUserEmail();
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(email).get();

    if (userDoc.exists) {
      return {
        'name': userDoc['name'] ?? 'Unknown User',
        'email': userDoc['email'] ?? 'No email',
      };
    } else {
      return {'name': 'User not found', 'email': 'No email'};
    }
  }

  void _signOut(BuildContext context) async {
    await _authService.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Center(
          child: Text('Profile'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      drawer: FutureBuilder<Map<String, String>>(
        future: _getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Drawer(
              child: Center(child: CircularProgressIndicator()),  // Loading indicator
            );
          }

          if (snapshot.hasError) {
            return Drawer(
              child: Center(child: Text('Error loading user data')),
            );
          }

          final userName = snapshot.data?['name'] ?? 'No name found';
          final userEmail = snapshot.data?['email'] ?? 'No email found';

          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Color(0xFF5DB8AE),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('assets/images/profile_placeholder.png'), // Placeholder image
                      ),
                      SizedBox(height: 8),
                      Text(
                        userName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                      Text(
                        userEmail,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Text('Home'),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                ),
                ListTile(
                  title: Text('Profile'),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/profile');
                  },
                ),
              ],
            ),
          );
        },
      ),
      body: Center( // Center the entire content
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,  // Vertically center
              crossAxisAlignment: CrossAxisAlignment.center, // Horizontally center
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 80,
                  backgroundImage: AssetImage('assets/images/profile_placeholder.png'), // Replace with user profile picture
                ),
                SizedBox(height: 16),
                // User Name and Email
                FutureBuilder<Map<String, String>>(
                  future: _getUserDetails(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();  // Show loading indicator while fetching data
                    }

                    if (snapshot.hasError) {
                      return Text('Error loading profile');
                    }

                    final userName = snapshot.data?['name'] ?? 'Unknown User';
                    final userEmail = snapshot.data?['email'] ?? 'No email';

                    return Column(
                      children: [
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5DB8AE),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          userEmail,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 32),
                // Edit Profile Button (Optional)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/editProfile'); // Add route to edit profile page
                  },
                  child: Text('Edit Profile'),
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
                // Sign Out Button
                ElevatedButton(
                  onPressed: () => _signOut(context),
                  child: Text('Sign Out'),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
