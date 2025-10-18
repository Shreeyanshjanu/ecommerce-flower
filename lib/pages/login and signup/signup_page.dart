import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bloom_boom/auth/signup_auth.dart';
import 'package:bloom_boom/pages/login%20and%20signup/login_page.dart';
import 'package:bloom_boom/utils/glass_snackbar.dart';
import 'package:lottie/lottie.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  bool isLoading = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  final TextEditingController confirmPwController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    pwController.dispose();
    confirmPwController.dispose();
    nameController.dispose();
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
                  'Hi!, Create Account',
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
                          controller: nameController,
                          style: TextStyle(color: Colors.yellow),
                          decoration: InputDecoration(
                            hintText: 'Name',
                            hintStyle: TextStyle(color: Colors.yellow),
                          ),
                        ),
                        SizedBox(height: 16),
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
                        SizedBox(height: 16),
                        TextField(
                          controller: confirmPwController,
                          obscureText: true,
                          obscuringCharacter: '✿',
                          style: TextStyle(color: Colors.yellow),
                          decoration: InputDecoration(
                            hintText: 'Confirm Password',
                            hintStyle: TextStyle(color: Colors.yellow),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextButton(
                          onPressed: isLoading ? null : () async {
                            String name = nameController.text.trim();
                            String email = emailController.text.trim();
                            String password = pwController.text.trim();
                            String confirmPassword = confirmPwController.text.trim();

                            // Validation: Check for empty fields
                            if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
                              showGlassSnackbar(
                                context,
                                'Please fill in all fields',
                                'assets/animations/snackbar_error.json',
                              );
                              return;
                            }

                            // Name validation
                            if (name.length < 2) {
                              showGlassSnackbar(
                                context,
                                'Name must be at least 2 characters long',
                                'assets/animations/snackbar_error.json',
                              );
                              return;
                            }

                            // Email validation
                            if (!email.contains('@') || !email.contains('.')) {
                              showGlassSnackbar(
                                context,
                                'Please enter a valid email address',
                                'assets/animations/snackbar_error.json',
                              );
                              return;
                            }

                            // Password length validation
                            if (password.length < 6) {
                              showGlassSnackbar(
                                context,
                                'Password must be at least 6 characters long',
                                'assets/animations/snackbar_error.json',
                              );
                              return;
                            }

                            // Password match validation
                            if (password != confirmPassword) {
                              showGlassSnackbar(
                                context,
                                'Passwords do not match',
                                'assets/animations/snackbar_error.json',
                              );
                              return;
                            }

                            setState(() => isLoading = true);

                            try {
                              await ref
                                  .read(signupProvider.notifier)
                                  .signup(name, email, password);

                              // Show success message
                              showGlassSnackbar(
                                context,
                                'Account created successfully! Please log in.',
                                'assets/animations/success.json',
                              );

                              // Navigate to login page after delay
                              Future.delayed(Duration(seconds: 2), () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginPage(),
                                  ),
                                );
                              });

                            } on FirebaseAuthException catch (e) {
                              String errorMessage;
                              String animationPath;

                              switch (e.code) {
                                case 'email-already-in-use':
                                  errorMessage = 'An account with this email already exists. Please sign in instead.';
                                  animationPath = 'assets/animations/snackbar_error.json';
                                  break;
                                case 'invalid-email':
                                  errorMessage = 'Invalid email format. Please check and try again.';
                                  animationPath = 'assets/animations/snackbar_error.json';
                                  break;
                                case 'operation-not-allowed':
                                  errorMessage = 'Email/password accounts are not enabled. Contact support.';
                                  animationPath = 'assets/animations/error.json';
                                  break;
                                case 'weak-password':
                                  errorMessage = 'Password is too weak. Please use a stronger password.';
                                  animationPath = 'assets/animations/snackbar_error.json';
                                  break;
                                case 'network-request-failed':
                                  errorMessage = 'Network error. Please check your connection.';
                                  animationPath = 'assets/animations/snackbar_error.json';
                                  break;
                                default:
                                  errorMessage = 'Signup failed: ${e.message ?? 'Unknown error'}';
                                  animationPath = 'assets/animations/error.json';
                              }

                              showGlassSnackbar(context, errorMessage, animationPath);
                            } catch (e) {
                              showGlassSnackbar(
                                context,
                                'An unexpected error occurred while creating account.',
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
                                  "Sign Up",
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Already have an account?'),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginPage(),
                                  ),
                                );
                              },
                              child: Text(
                                'Sign In',
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
