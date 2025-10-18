import 'dart:math';
import 'package:cloud_functions/cloud_functions.dart';

class EmailService {
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Generate 6-digit OTP
  static String generateOtp() {
    return (Random().nextInt(900000) + 100000).toString();
  }

  /// Send OTP email via Cloud Functions
  static Future<bool> sendOtpEmail({
    required String email,
    required String otp,
    String purpose = 'verification',
  }) async {
    try {
      print('📧 Sending OTP to: $email');
      print('🔢 OTP: $otp');
      print('📋 Purpose: $purpose');

      final callable = _functions.httpsCallable('sendOtpEmail');

      // Call Cloud Function with timeout
      final result = await callable.call<Map<String, dynamic>>({
        'email': email,
        'otp': otp,
        'purpose': purpose,
      }).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - Check your internet connection');
        },
      );

      print('✅ Cloud Function Response: ${result.data}');

      return result.data['success'] == true;
    } on FirebaseFunctionsException catch (e) {
      print('❌ Firebase Functions Error:');
      print('   Code: ${e.code}');
      print('   Message: ${e.message}');
      print('   Details: ${e.details}');
      
      // Provide user-friendly error messages
      if (e.code == 'unavailable') {
        throw Exception('Network error - Please check your internet connection');
      } else if (e.code == 'not-found') {
        throw Exception('Email service not configured - Contact support');
      } else if (e.code == 'invalid-argument') {
        throw Exception('Invalid email address');
      } else {
        throw Exception('Failed to send email: ${e.message}');
      }
    } catch (e) {
      print('❌ Unexpected error sending OTP: $e');
      throw Exception('Failed to send verification email. Please try again.');
    }
  }

  /// Test Cloud Function connection
  static Future<bool> testConnection() async {
    try {
      final callable = _functions.httpsCallable('testEmail');
      final result = await callable.call();
      print('✅ Test connection successful: ${result.data}');
      return true;
    } catch (e) {
      print('❌ Test connection failed: $e');
      return false;
    }
  }
}
