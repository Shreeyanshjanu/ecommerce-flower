import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bloom_boom/auth/pw_reset_provider.dart';
import 'package:bloom_boom/utils/glass_snackbar.dart';

class PwResetPage extends ConsumerStatefulWidget {
  const PwResetPage({Key? key}) : super(key: key);

  @override
  ConsumerState<PwResetPage> createState() => _PwResetPageState();
}

class _PwResetPageState extends ConsumerState<PwResetPage> {
  final TextEditingController emailContoller = TextEditingController();

  @override
  void dispose() {
    emailContoller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/flower.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Enter the email to reset the password',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    letterSpacing: 1.2,
                    decoration: TextDecoration.none,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: emailContoller,
                  style: TextStyle(color: Colors.yellow),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(color: Colors.yellow),
                  ),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () async {
                    final email = emailContoller.text.trim();

                    // Basic validation
                    if (email.isEmpty) {
                      showGlassSnackbar(
                        context,
                        'Please enter your email.',
                        'assets/animations/snackbar_error.json',
                      );
                      return;
                    }
                    if (!email.contains('@') || !email.contains('.')) {
                      showGlassSnackbar(
                        context,
                        'Please enter a valid email address.',
                        'assets/animations/snackbar_error.json',
                      );
                      return;
                    }

                    try {
                      await ref
                          .read(pwResetProvider.notifier)
                          .sendPasswordResetEmail(email);
                      showGlassSnackbar(
                        context,
                        'Reset link sent! Check your inbox.',
                        'assets/animations/success.json',
                      );
                    } on FirebaseAuthException catch (e) {
                      showGlassSnackbar(
                        context,
                        e.message ?? 'Failed to send reset email.',
                        'assets/animations/error.json',
                      );
                    } catch (e) {
                      showGlassSnackbar(
                        context,
                        'An unexpected error occurred.',
                        'assets/animations/error.json',
                      );
                    }
                  },
                  child: Text(
                    'Send Reset Link',
                    style: TextStyle(color: Colors.white, fontSize: 15),
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
