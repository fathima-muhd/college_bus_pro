import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Get the current logged-in user
  User? getCurrentUser() {
    return _auth.currentUser; // Returns null if no user is logged in
  }

  // ✅ Get user role from Firestore
  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection("users").doc(uid).get();
      return userDoc.exists ? userDoc.get("role") : null;
    } catch (e) {
      print("Error fetching user role: $e");
      return null;
    }
  }

  // ✅ Register User
  Future<String?> registerUser(String name, String email, String password, String role) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'role': role,
        'uid': userCredential.user!.uid,
      });

      return null; // Success
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  // ✅ Login User
  Future<String?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ✅ Pass the UID to getUserRole
      String? role = await getUserRole(userCredential.user!.uid);
      return role ?? "Unknown";
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  // ✅ Logout Function
  Future<void> logout() async {
    await _auth.signOut();
  }
}
