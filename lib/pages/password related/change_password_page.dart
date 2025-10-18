import 'dart:ui';
import 'package:bloom_boom/services/email_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isLoading = false;
  bool _isOtpSent = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  String _generatedOtp = '';

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/settings_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 400),
                    padding: EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Back Button
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),

                        // Title
                        Text(
                          'Change Password',
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Secure your account',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 30),

                        if (!_isOtpSent) ...[
                          // Current Password Field
                          _buildPasswordField(
                            controller: _currentPasswordController,
                            hint: 'Current Password',
                            icon: Icons.lock_outline,
                            obscure: _obscureCurrentPassword,
                            onToggle: () => setState(() =>
                                _obscureCurrentPassword =
                                    !_obscureCurrentPassword),
                          ),
                          SizedBox(height: 16),

                          // New Password Field
                          _buildPasswordField(
                            controller: _newPasswordController,
                            hint: 'New Password',
                            icon: Icons.lock,
                            obscure: _obscureNewPassword,
                            onToggle: () => setState(
                                () => _obscureNewPassword = !_obscureNewPassword),
                          ),
                          SizedBox(height: 16),

                          // Confirm Password Field
                          _buildPasswordField(
                            controller: _confirmPasswordController,
                            hint: 'Confirm New Password',
                            icon: Icons.lock_clock,
                            obscure: _obscureConfirmPassword,
                            onToggle: () => setState(() =>
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword),
                          ),
                          SizedBox(height: 30),

                          // Send OTP Button
                          _buildButton(
                            text: 'Send OTP',
                            onPressed: _sendOtp,
                          ),
                        ] else ...[
                          // OTP Info
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.email_outlined,
                                    color: Colors.white, size: 40),
                                SizedBox(height: 12),
                                Text(
                                  'OTP sent to your email',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _auth.currentUser?.email ?? '',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24),

                          // OTP Input Field
                          _buildOtpField(),
                          SizedBox(height: 16),

                          // Resend OTP
                          TextButton(
                            onPressed: _isLoading ? null : _sendOtp,
                            child: Text(
                              'Resend OTP',
                              style: TextStyle(
                                color: _isLoading 
                                    ? Colors.white30 
                                    : Colors.white70,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          SizedBox(height: 24),

                          // Verify & Change Password Button
                          _buildButton(
                            text: 'Verify & Change Password',
                            onPressed: _verifyOtpAndChangePassword,
                          ),
                        ],

                        SizedBox(height: 16),

                        // Cancel Button
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white70, fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.white70, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off : Icons.visibility,
              color: Colors.white70,
              size: 20,
            ),
            onPressed: onToggle,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildOtpField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _otpController,
        keyboardType: TextInputType.number,
        maxLength: 6,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          letterSpacing: 8,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          hintText: '000000',
          hintStyle: TextStyle(color: Colors.white30, letterSpacing: 8),
          border: InputBorder.none,
          counterText: '',
          contentPadding: EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }

  Widget _buildButton({required String text, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF079A3D), Color(0xFF05C46B)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF079A3D).withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }

  Future<void> _sendOtp() async {
    // Validate inputs
    if (!_isOtpSent) {
      if (_currentPasswordController.text.isEmpty ||
          _newPasswordController.text.isEmpty ||
          _confirmPasswordController.text.isEmpty) {
        _showError('Please fill all fields');
        return;
      }

      if (_newPasswordController.text != _confirmPasswordController.text) {
        _showError('Passwords do not match');
        return;
      }

      if (_newPasswordController.text.length < 6) {
        _showError('Password must be at least 6 characters');
        return;
      }

      // Verify current password
      setState(() => _isLoading = true);
      try {
        final user = _auth.currentUser;
        if (user == null) {
          setState(() => _isLoading = false);
          _showError('No user logged in');
          return;
        }

        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text,
        );
        await user.reauthenticateWithCredential(credential);
      } catch (e) {
        setState(() => _isLoading = false);
        _showError('Current password is incorrect');
        return;
      }
    }

    // Generate OTP
    _generatedOtp = EmailService.generateOtp();

    // Send OTP via Cloud Function
    try {
      print('🚀 Attempting to send OTP email...');
      
      final success = await EmailService.sendOtpEmail(
        email: _auth.currentUser!.email!,
        otp: _generatedOtp,
        purpose: 'password-change',
      );

      if (success) {
        setState(() {
          _isOtpSent = true;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ OTP sent to ${_auth.currentUser?.email}'),
            backgroundColor: Color(0xFF079A3D),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        setState(() => _isLoading = false);
        _showError('Failed to send OTP. Please try again.');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _verifyOtpAndChangePassword() async {
    if (_otpController.text.isEmpty) {
      _showError('Please enter OTP');
      return;
    }

    if (_otpController.text != _generatedOtp) {
      _showError('Invalid OTP');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Change password
      await _auth.currentUser?.updatePassword(_newPasswordController.text);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Password changed successfully!'),
            backgroundColor: Color(0xFF079A3D),
          ),
        );
      }
    } catch (e) {
      _showError('Error changing password: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
  }
}
