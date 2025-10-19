import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// List of admin emails (hardcoded for security)
  static const List<String> ADMIN_EMAILS = [
    'arthurmorgan5984@gmail.com',  // Replace with YOUR email
    'admin@bloomboom.com',   // Add more admin emails here
  ];

  /// Check if current user is admin
  static Future<bool> isAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Method 1: Check hardcoded list (fast, secure)
      if (ADMIN_EMAILS.contains(user.email?.toLowerCase())) {
        return true;
      }

      // Method 2: Check Firestore (flexible, can change without app update)
      final doc = await _firestore.collection('admins').doc(user.uid).get();
      if (doc.exists) {
        return doc.data()?['isAdmin'] == true;
      }

      return false;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  /// Get current user role
  static Future<String> getUserRole() async {
    final isAdminUser = await isAdmin();
    return isAdminUser ? 'admin' : 'user';
  }

  /// Check if email is admin (before login)
  static bool isAdminEmail(String email) {
    return ADMIN_EMAILS.contains(email.toLowerCase());
  }
}
