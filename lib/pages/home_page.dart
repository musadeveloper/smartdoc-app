import 'package:flutter/material.dart';
import '/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  final AuthService _authService = AuthService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _signOut(BuildContext context) async {
    await _authService.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Function to navigate to Request Diagnosis Page
  void _navigateToRequestDiagnosis(BuildContext context) {
    Navigator.pushNamed(context, '/requestDiagnosis');
  }

  // Function to navigate to View Past Diagnosis Page
  void _navigateToViewPastDiagnosis(BuildContext context) {
    Navigator.pushNamed(context, '/viewPastDiagnosis');
  }

  // Function to get Username
  Future<String> _getUserName() async {

    final String email = _authService.getCurrentUserEmail();


    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(email).get();

    if (userDoc.exists) {

      return userDoc['name'] ?? 'Unknown User';
    } else {
      return 'User not found';
    }
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
          child: Text('Home'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      drawer: FutureBuilder<String>(
        future: _getUserName(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Drawer(
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return Drawer(
              child: Center(child: Text('Error loading user data')),
            );
          }

          final userName = snapshot.data ?? 'No name found';

          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Color(0xFF5DB8AE),
                  ),
                  child: Text(
                    userName,  // Display user name
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
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
                    Navigator.pushNamed(context, '/profile');  // Navigate to Profile page
                  },
                ),
                // Additional Drawer items can go here (like settings, help, etc.)
              ],
            ),
          );
        },
      ),
      body: Column(
        children: [
          Container(
            color: Color(0xFF5DB8AE),
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                    'The Smart Doctor app is a digital health assistant that allows users to request diagnoses, manage health records, and interact with medical services, all in a seamless and user-friendly interface.',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
                Image.asset(
                  'assets/images/vecteezy_3d-doctor-character-jump-from-phone-screen-with-megaphone_36485039.png',
                  height: 150,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                GestureDetector(
                  onTap: () => _navigateToRequestDiagnosis(context),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 16.0),
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Color(0xFF5DB8AE),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                      child: Text(
                        'Request a Diagnosis',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _navigateToViewPastDiagnosis(context),
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Color(0xFF5DB8AE),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                      child: Text(
                        'View Past Diagnosis',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
