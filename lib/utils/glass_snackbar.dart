import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void showGlassSnackbar(BuildContext context, String message, String lottieAsset) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    lottieAsset,
                    width: 200,
                    height: 200,
                    repeat: false,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
