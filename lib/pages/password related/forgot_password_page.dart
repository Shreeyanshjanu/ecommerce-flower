import 'dart:ui';
import 'package:bloom_boom/pages/login%20and%20signup/login_page.dart';
import 'package:bloom_boom/services/email_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController =
      TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  String _generatedOtp = '';

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Enter your email to reset password',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 30),

                        if (!_isOtpSent) ...[
                          // Email Field
                          _buildTextField(
                            controller: _emailController,
                            hint: 'Email Address',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 30),

                          // Send OTP Button
                          _buildButton(
                            text: 'Send OTP',
                            onPressed: _sendOtp,
                          ),
                        ] else if (!_isOtpVerified) ...[
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
                                  'OTP sent to',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _emailController.text,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24),

                          // OTP Field
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

                          // Verify OTP Button
                          _buildButton(
                            text: 'Verify OTP',
                            onPressed: _verifyOtp,
                          ),
                        ] else ...[
                          // Success message
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.check_circle, 
                                    color: Colors.white, size: 50),
                                SizedBox(height: 12),
                                Text(
                                  'OTP Verified Successfully!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Check your email for password reset link',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24),

                          // Back to Login Button
                          _buildButton(
                            text: 'Back to Login',
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => LoginPage()),
                                (route) => false,
                              );
                            },
                          ),
                        ],

                        SizedBox(height: 16),

                        // Back to Login
                        if (!_isOtpVerified)
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Back to Login',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
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
        keyboardType: keyboardType,
        style: TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white70, fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.white70, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
    if (_emailController.text.trim().isEmpty) {
      _showError('Please enter your email');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check if email exists
      final methods =
          await _auth.fetchSignInMethodsForEmail(_emailController.text.trim());
      if (methods.isEmpty) {
        setState(() => _isLoading = false);
        _showError('Email not registered');
        return;
      }

      // Generate OTP
      _generatedOtp = EmailService.generateOtp();

      print('🚀 Attempting to send OTP for password reset...');

      // Send OTP via Cloud Function
      final success = await EmailService.sendOtpEmail(
        email: _emailController.text.trim(),
        otp: _generatedOtp,
        purpose: 'password-reset',
      );

      if (success) {
        setState(() {
          _isOtpSent = true;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ OTP sent to ${_emailController.text}'),
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

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().isEmpty) {
      _showError('Please enter OTP');
      return;
    }

    if (_otpController.text != _generatedOtp) {
      _showError('Invalid OTP. Please check and try again.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Send Firebase password reset email after OTP verification
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());

      setState(() {
        _isOtpVerified = true;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Password reset link sent to your email!'),
          backgroundColor: Color(0xFF079A3D),
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error sending reset link: ${e.toString()}');
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
