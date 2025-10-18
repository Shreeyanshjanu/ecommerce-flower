import 'package:bloom_boom/pages/password%20related/forgot_password_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bloom_boom/auth/login_auth.dart';
import 'package:bloom_boom/pages/home%20pages/home_page.dart';
import 'package:bloom_boom/pages/password%20related/pw_reset_page.dart';
import 'package:bloom_boom/pages/login%20and%20signup/signup_page.dart';
import 'package:bloom_boom/utils/glass_snackbar.dart';
import 'package:lottie/lottie.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool isLoading = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/flower.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi!',
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    letterSpacing: 1.2,
                    decoration: TextDecoration.none,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.transparent,
                        blurRadius: 2,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Container(
                    height: 400,
                    width: 300,
                    child: Column(
                      children: [
                        TextField(
                          controller: emailController,
                          style: TextStyle(color: Colors.yellow),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(color: Colors.yellow),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: pwController,
                          obscureText: true,
                          obscuringCharacter: '✿',
                          style: TextStyle(color: Colors.yellow),
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: TextStyle(color: Colors.yellow),
                          ),
                        ),

                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ForgotPasswordPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Colors.white70,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),

                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  String email = emailController.text.trim();
                                  String password = pwController.text.trim();

                                  // Validation: Check for empty fields
                                  if (email.isEmpty || password.isEmpty) {
                                    showGlassSnackbar(
                                      context,
                                      'Please fill in all fields',
                                      'assets/animations/snackbar_error.json',
                                    );
                                    return;
                                  }

                                  // Basic email validation
                                  if (!email.contains('@') ||
                                      !email.contains('.')) {
                                    showGlassSnackbar(
                                      context,
                                      'Please enter a valid email address',
                                      'assets/animations/snackbar_error.json',
                                    );
                                    return;
                                  }

                                  setState(() => isLoading = true);

                                  try {
                                    await ref
                                        .read(LoginProvider.notifier)
                                        .Login(email, password);

                                    // Show success message
                                    showGlassSnackbar(
                                      context,
                                      'Login successful! Welcome back.',
                                      'assets/animations/success.json',
                                    );

                                    // Navigate to home or dashboard after delay
                                    Future.delayed(Duration(seconds: 2), () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => HomePage(),
                                        ),
                                      );
                                    });
                                  } on FirebaseAuthException catch (e) {
                                    String errorMessage;
                                    String animationPath;

                                    switch (e.code) {
                                      case 'user-not-found':
                                        errorMessage =
                                            'No account found for this email. Please sign up first.';
                                        animationPath =
                                            'assets/animations/error.json';
                                        break;
                                      case 'wrong-password':
                                        errorMessage =
                                            'Incorrect password. Please try again.';
                                        animationPath =
                                            'assets/animations/error.json';
                                        break;
                                      case 'invalid-email':
                                        errorMessage =
                                            'Invalid email format. Please check and try again.';
                                        animationPath =
                                            'assets/animations/snackbar_error.json';
                                        break;
                                      case 'user-disabled':
                                        errorMessage =
                                            'This account has been disabled. Contact support.';
                                        animationPath =
                                            'assets/animations/error.json';
                                        break;
                                      case 'too-many-requests':
                                        errorMessage =
                                            'Too many failed attempts. Please try again later.';
                                        animationPath =
                                            'assets/animations/snackbar_error.json';
                                        break;
                                      case 'network-request-failed':
                                        errorMessage =
                                            'Network error. Please check your connection.';
                                        animationPath =
                                            'assets/animations/snackbar_error.json';
                                        break;
                                      default:
                                        errorMessage =
                                            'Login failed: ${e.message ?? 'Unknown error'}';
                                        animationPath =
                                            'assets/animations/error.json';
                                    }

                                    showGlassSnackbar(
                                      context,
                                      errorMessage,
                                      animationPath,
                                    );
                                  } catch (e) {
                                    showGlassSnackbar(
                                      context,
                                      'An unexpected error occurred. Please try again.',
                                      'assets/animations/error.json',
                                    );
                                  } finally {
                                    setState(() => isLoading = false);
                                  }
                                },
                          style: TextButton.styleFrom(
                            minimumSize: Size(150, 50),
                            backgroundColor: Colors.transparent,
                          ),
                          child: isLoading
                              ? SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Lottie.asset(
                                    'assets/animations/login_button_animation.json',
                                    fit: BoxFit.contain,
                                  ),
                                )
                              : Text(
                                  "Login",
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Don\'t have an account?'),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignupPage(),
                                  ),
                                );
                              },
                              child: Text(
                                'Sign Up',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Forgot Password?'),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PwResetPage(),
                                  ),
                                );
                              },
                              child: Text(
                                'Reset password',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
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
