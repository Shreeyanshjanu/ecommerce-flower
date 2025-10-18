import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AboutDeveloperPage extends StatefulWidget {
  const AboutDeveloperPage({Key? key}) : super(key: key);

  @override
  State<AboutDeveloperPage> createState() => _AboutDeveloperPageState();
}

class _AboutDeveloperPageState extends State<AboutDeveloperPage>
    with SingleTickerProviderStateMixin {
  // ignore: unused_field
  String _displayedText = '';
  final String _fullText =
      'Bloom Boom is your ultimate destination for fresh, beautiful flowers delivered right to your doorstep. Browse curated collections, discover seasonal blooms, and send love with just a tap. Brighten someone\'s day—or yours—with the perfect bouquet!';
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    _timer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (_currentIndex < _fullText.length) {
        setState(() {
          _displayedText = _fullText.substring(0, _currentIndex + 1);
          _currentIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB94CD5), Color(0xFF9B4CB8)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main profile card
              Card(
                elevation: 40.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Container(
                  width: 340,
                  height: 160,

                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          // Profile Photo with rounded corners
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.asset(
                              'assets/images/developer_profile.jpg', // Replace with your image path
                              width: 140,
                              height: 140,
                              fit: BoxFit.cover,
                            ),
                          ),

                          SizedBox(width: 20),

                          // Right side content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name
                                Text(
                                  'Shreeyansh Janu',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),

                                SizedBox(height: 8),

                                // Job Title
                                Text(
                                  'Flutter Developer | ML Enthusiast',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 0), // Space between main card and bottom cards
              // Two cards below
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Left card
                  Card(
                    elevation: 8.0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Container(
                      width: 165,
                      height: 300,
                      padding: EdgeInsets.all(0.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // GitHub Row
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // GitHub Lottie Icon with constraints
                              SizedBox(
                                width: 52,
                                height: 52,
                                child: Lottie.asset(
                                  'assets/animations/github.json',
                                  fit: BoxFit.contain,
                                ),
                              ),

                              SizedBox(width: 8),

                              // GitHub text and username
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Github',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      'Shreeyanshjanu',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // GitHub Lottie Icon with constraints
                              SizedBox(
                                width: 52,
                                height: 52,
                                child: Lottie.asset(
                                  'assets/animations/instagram.json',
                                  fit: BoxFit.contain,
                                ),
                              ),

                              SizedBox(width: 8),

                              // GitHub text and username
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Instagram',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      'shreeyansh_janu',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // GitHub Lottie Icon with constraints
                              SizedBox(
                                width: 52,
                                height: 52,
                                child: Lottie.asset(
                                  'assets/animations/gmail.json',
                                  fit: BoxFit.contain,
                                ),
                              ),

                              SizedBox(width: 8),

                              // GitHub text and username
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '@Gmail',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      'arthurmorgan5984',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // GitHub Lottie Icon with constraints
                              SizedBox(
                                width: 52,
                                height: 52,
                                child: Lottie.asset(
                                  'assets/animations/linkedin.json',
                                  fit: BoxFit.contain,
                                ),
                              ),

                              SizedBox(width: 8),

                              // GitHub text and username
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Linkedin',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      'shreeyanshjanu',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // GitHub Lottie Icon with constraints
                              SizedBox(
                                width: 52,
                                height: 52,
                                child: Lottie.asset(
                                  'assets/animations/earth.json',
                                  fit: BoxFit.contain,
                                ),
                              ),

                              SizedBox(width: 8),

                              // GitHub text and username
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Website',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      'coming soon',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(width: 0), // Space between the two cards
                  // Right card
                  Card(
                    elevation: 8.0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Container(
                      width: 165,
                      height: 300,
                      padding: EdgeInsets.all(15.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _displayedText,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontFamily: 'monospace',
                                height: 1.6,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
