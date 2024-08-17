import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in with email and password
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print(e); // Handle errors as needed
      return null;
    }
  }

  // Method to get the current user's email
  String getCurrentUserEmail() {
    return _auth.currentUser?.email ?? 'Guest';
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Stream to get authentication status
  Stream<User?> get user {
    return _auth.authStateChanges();
  }
}
