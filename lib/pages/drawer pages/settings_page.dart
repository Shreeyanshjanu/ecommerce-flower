import 'dart:ui';
import 'package:bloom_boom/auth/cart_provider.dart';
import 'package:bloom_boom/pages/password%20related/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:bloom_boom/pages/login%20and%20signup/login_page.dart';
import 'package:bloom_boom/utils/glass_snackbar.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/settings_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMenuItem(
                          icon: 'assets/animations/userdetail.json',
                          label: 'My Profile',
                          onTap: () {
                            // Navigate to Profile Page
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ProfilePage()),
                            );
                          },
                        ),
                        SizedBox(height: 20),
                        Divider(
                          color: Colors.white.withOpacity(0.3),
                          thickness: 1,
                        ),
                        SizedBox(height: 20),
                        _buildMenuItem(
                          icon: 'assets/animations/logout.json',
                          label: 'Logout',
                          onTap: () => logOut(),
                        ),
                        SizedBox(height: 20),
                        Divider(
                          color: Colors.white.withOpacity(0.3),
                          thickness: 1,
                        ),
                        SizedBox(height: 20),
                        _buildMenuItem(
                          icon: 'assets/animations/delete.json',
                          label: 'Delete Account',
                          onTap: () => deleteAccount(context),
                          isDestructive: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: Lottie.asset(icon, repeat: true),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isDestructive ? Colors.redAccent : Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> logOut() async {
    try {
      await ref.read(cartProvider.notifier).clearCart();
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
        );
      }
    } catch (e) {
      print('Error logging out: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account'),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await ref.read(cartProvider.notifier).clearCart();
        await user.delete();

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginPage()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        showGlassSnackbar(
          context,
          'Please re-authenticate to delete your account.',
          'assets/animations/error.json',
        );
      } else {
        showGlassSnackbar(
          context,
          'Error deleting account: ${e.message}',
          'assets/animations/error.json',
        );
      }
    }
  }
}
