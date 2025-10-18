import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:bloom_boom/config/api_keys.dart';

class FlowerSearchService {
  static const String _pexelsBaseUrl = 'https://api.pexels.com/v1';

  /// Search for ONLY flower images from Pexels (filtered)
  Future<List<Map<String, dynamic>>> searchFlowers(String query) async {
    try {
      print('🔍 Searching Pexels for: $query');

      final response = await http.get(
        Uri.parse(
          '$_pexelsBaseUrl/search?query=$query flower nature&per_page=15',
        ),
        headers: {'Authorization': ApiKeys.pexelsApiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final photos = data['photos'] as List;

        // Filter out images with "person" or "people" in description
        final flowerPhotos = photos.where((photo) {
          final altText = (photo['alt'] ?? '').toLowerCase();
          // Exclude images that mention people/humans
          return !altText.contains('person') &&
              !altText.contains('people') &&
              !altText.contains('woman') &&
              !altText.contains('man') &&
              !altText.contains('girl') &&
              !altText.contains('boy') &&
              !altText.contains('child') &&
              !altText.contains('human');
        }).toList();

        print('✅ Found ${flowerPhotos.length} flower-only images');

        return flowerPhotos.take(5).map((photo) {
          return {
            'id': photo['id'].toString(),
            'url': photo['src']['large'],
            'photographer': photo['photographer'],
            'description': '$query',
          };
        }).toList();
      } else {
        print('❌ Pexels API error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error searching flowers: $e');
      return [];
    }
  }

  /// Check if flower already exists in Firebase Storage
  Future<bool> doesFlowerExist(String folderName, String flowerName) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('flowers')
          .child(folderName);

      final listResult = await storageRef.listAll();

      // Check if any file contains the flower name
      final normalizedSearchName = flowerName.toLowerCase().replaceAll(
        ' ',
        '_',
      );

      for (var item in listResult.items) {
        final fileName = item.name.toLowerCase();
        if (fileName.contains(normalizedSearchName)) {
          print('⚠️ Flower already exists: ${item.name}');
          return true;
        }
      }

      return false;
    } catch (e) {
      print('❌ Error checking existence: $e');
      return false;
    }
  }

  /// Get existing flower data from Firebase
  Future<Map<String, String>?> getExistingFlower(
    String folderName,
    String flowerName,
  ) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('flowers')
          .child(folderName);

      final listResult = await storageRef.listAll();
      final normalizedSearchName = flowerName.toLowerCase().replaceAll(
        ' ',
        '_',
      );

      for (var item in listResult.items) {
        final fileName = item.name.toLowerCase();
        if (fileName.contains(normalizedSearchName)) {
          print('✅ Found existing flower: ${item.name}');

          final imageUrl = await item.getDownloadURL();
          final metadata = await item.getMetadata();

          return {
            'imageUrl': imageUrl,
            'flowerName': metadata.customMetadata?['flower_name'] ?? flowerName,
            'folderName': folderName,
          };
        }
      }

      return null;
    } catch (e) {
      print('❌ Error getting existing flower: $e');
      return null;
    }
  }

  /// Detect dominant color
  Future<String> detectDominantColor(String imageUrl) async {
    try {
      print('🎨 Detecting color for image...');

      final response = await http.get(Uri.parse(imageUrl));
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/temp_flower_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await file.writeAsBytes(response.bodyBytes);

      final image = FileImage(file);
      final paletteGenerator = await PaletteGenerator.fromImageProvider(image);

      final dominantColor =
          paletteGenerator.dominantColor?.color ?? Colors.grey;

      await file.delete();

      final folderName = _colorToFolderName(dominantColor);
      print('✅ Detected color: $folderName');

      return folderName;
    } catch (e) {
      print('❌ Error detecting color: $e');
      return 'other_flower';
    }
  }

  /// Map color to folder name
  String _colorToFolderName(Color color) {
    final hslColor = HSLColor.fromColor(color);
    final hue = hslColor.hue;
    final saturation = hslColor.saturation;
    final lightness = hslColor.lightness;

    if (saturation < 0.15) {
      if (lightness > 0.85) return 'white_flower';
      if (lightness < 0.25) return 'black_flower';
      return 'white_flower';
    }

    if (hue >= 45 && hue < 75) return 'yellow_flower';
    if (hue >= 270 && hue < 330) return 'purple_flower';
    if (hue >= 330 || hue < 30) return 'red_flower';
    if (hue >= 300 && hue < 350) return 'pink_flower';
    if (hue >= 80 && hue < 170) return 'green_flower';
    if (hue >= 180 && hue < 270) return 'blue_flower';
    if (hue >= 20 && hue < 45) return 'orange_flower';

    return 'other_flower';
  }

  /// Upload image to Firebase Storage
  Future<String?> uploadToFirebase(
    String imageUrl,
    String folderName,
    String flowerName,
  ) async {
    try {
      print('📤 Uploading to Firebase: flowers/$folderName/');

      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        print('❌ Failed to download image');
        return null;
      }

      final bytes = response.bodyBytes;

      // Generate unique but searchable filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final sanitizedName = flowerName.toLowerCase().replaceAll(
        RegExp(r'[^a-zA-Z0-9]'),
        '_',
      );
      final filename = '${sanitizedName}_$timestamp.jpg';

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('flowers')
          .child(folderName)
          .child(filename);

      await storageRef.putData(
        bytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'source': 'pexels',
            'flower_name': flowerName,
            'search_query': flowerName,
            'uploaded_at': DateTime.now().toIso8601String(),
          },
        ),
      );

      final downloadUrl = await storageRef.getDownloadURL();
      print('✅ Uploaded successfully: $filename');

      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading to Firebase: $e');
      return null;
    }
  }

  /// Complete search and save workflow WITH DUPLICATE PREVENTION
  Future<Map<String, dynamic>> searchAndSaveFlower(String query) async {
    List<Map<String, String>> savedFlowers = [];
    List<String> skippedFlowers = [];
    Map<String, int> folderCounts = {};

    try {
      // Normalize query
      final normalizedQuery = query.trim().toLowerCase();

      // 1. Search for flowers on Pexels
      final searchResults = await searchFlowers(normalizedQuery);

      if (searchResults.isEmpty) {
        return {
          'success': false,
          'message': 'No flower-only images found for "$query"',
          'flowers': [],
          'folders': {},
          'skipped': [],
          'existingFlower': null,
        };
      }

      // 2. Process ONLY THE FIRST matching result per folder
      Map<String, bool> folderProcessed = {};

      for (var result in searchResults) {
        try {
          // Detect dominant color
          final folderName = await detectDominantColor(result['url']);

          // Skip if we already processed this folder
          if (folderProcessed[folderName] == true) {
            print('⏭️ Skipping - already have image in $folderName');
            continue;
          }

          // Check if flower already exists
          final exists = await doesFlowerExist(folderName, normalizedQuery);

          if (exists) {
            print('⚠️ Flower "$query" already exists in $folderName');

            // Get existing flower data
            final existingFlowerData = await getExistingFlower(
              folderName,
              normalizedQuery,
            );

            return {
              'success': false,
              'message': 'Flower already exists',
              'flowers': [],
              'folders': {},
              'skipped': ['Already exists'],
              'existingFlower': existingFlowerData, // Return existing data
            };
          }

          // Upload to Firebase
          final firebaseUrl = await uploadToFirebase(
            result['url'],
            folderName,
            normalizedQuery,
          );

          if (firebaseUrl != null) {
            savedFlowers.add({
              'url': firebaseUrl,
              'name': normalizedQuery,
              'folder': folderName,
              'photographer': result['photographer'],
            });

            folderCounts[folderName] = (folderCounts[folderName] ?? 0) + 1;
            folderProcessed[folderName] = true; // Mark folder as processed

            // Stop after saving ONE image
            print('✅ Saved 1 image - stopping search');
            break;
          }
        } catch (e) {
          print('❌ Error processing flower: $e');
        }
      }

      return {
        'success': savedFlowers.isNotEmpty,
        'message': savedFlowers.isNotEmpty
            ? 'Saved ${savedFlowers.length} flower'
            : 'No suitable images found',
        'flowers': savedFlowers,
        'folders': folderCounts,
        'skipped': skippedFlowers,
        'existingFlower': null,
      };
    } catch (e) {
      print('❌ Error in search workflow: $e');
      return {
        'success': false,
        'message': 'Error: $e',
        'flowers': [],
        'folders': {},
        'skipped': [],
        'existingFlower': null,
      };
    }
  }
}
