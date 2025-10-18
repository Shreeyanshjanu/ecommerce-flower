import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:bloom_boom/pages/functionslities/category_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SeeAllWidget {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => _SeeAllDialog(),
    );
  }
}

class _SeeAllDialog extends StatefulWidget {
  @override
  State<_SeeAllDialog> createState() => _SeeAllDialogState();
}

class _SeeAllDialogState extends State<_SeeAllDialog> {
  List<Map<String, String>> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  /// Load all categories dynamically from Firebase Storage
  Future<void> _loadCategories() async {
    try {
      print('🔄 Loading categories from Firebase...');
      
      final storageRef = FirebaseStorage.instance.ref('flowers');
      final listResult = await storageRef.listAll();

      List<Map<String, String>> loadedCategories = [];

      // Loop through all folders in 'flowers/'
      for (var folderRef in listResult.prefixes) {
        try {
          final folderName = folderRef.name;
          print('📁 Found folder: $folderName');

          // Get first image from this folder as icon
          final folderItems = await folderRef.listAll();
          
          if (folderItems.items.isNotEmpty) {
            final firstImageUrl = await folderItems.items.first.getDownloadURL();
            
            // Convert folder name to display name
            final displayName = _formatCategoryName(folderName);

            loadedCategories.add({
              'imageUrl': firstImageUrl,
              'folder': folderName,
              'name': displayName,
            });

            print('✅ Added category: $displayName');
          }
        } catch (e) {
          print('❌ Error loading folder ${folderRef.name}: $e');
        }
      }

      // Sort categories alphabetically
      loadedCategories.sort((a, b) => a['name']!.compareTo(b['name']!));

      setState(() {
        categories = loadedCategories;
        isLoading = false;
      });

      print('✅ Loaded ${categories.length} categories');
    } catch (e) {
      print('❌ Error loading categories: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Format folder name to display name
  /// "yellow_flower" → "Yellow Flowers"
  /// "red_flower" → "Red Flowers"
  String _formatCategoryName(String folderName) {
    return folderName
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ') + 's';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              constraints: BoxConstraints(maxHeight: 600, maxWidth: 400),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All Categories',
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Content - Loading or Grid
                  Expanded(
                    child: isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : categories.isEmpty
                            ? Center(
                                child: Text(
                                  'No categories found',
                                  style: TextStyle(
                                    decoration: TextDecoration.none,
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 1,
                                ),
                                itemCount: categories.length,
                                itemBuilder: (context, index) {
                                  final category = categories[index];
                                  return _buildCategoryItem(
                                    context,
                                    category['imageUrl']!,
                                    category['folder']!,
                                    category['name']!,
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String imageUrl,
    String folderName,
    String categoryName,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryPage(
              categoryFolder: folderName,
              categoryName: categoryName,
              categoryImage: imageUrl, // Pass Firebase URL
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              // Category Image from Firebase
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholder: (context, url) => Container(
                  color: Colors.white.withOpacity(0.1),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.white.withOpacity(0.1),
                  child: Icon(
                    Icons.local_florist,
                    color: Colors.white70,
                    size: 40,
                  ),
                ),
              ),

              // Category Label Overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    categoryName.replaceAll('Flowers', '').trim(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
