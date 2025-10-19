import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/admin_service.dart';

/// Provider to check if current user is admin
final isAdminProvider = StreamProvider<bool>((ref) async* {
  final auth = FirebaseAuth.instance;
  
  await for (final user in auth.authStateChanges()) {
    if (user == null) {
      yield false;
    } else {
      yield await AdminService.isAdmin();
    }
  }
});

/// Provider for user role (admin or user)
final userRoleProvider = FutureProvider<String>((ref) async {
  return await AdminService.getUserRole();
});
