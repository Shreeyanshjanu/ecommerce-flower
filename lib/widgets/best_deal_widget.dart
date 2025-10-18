import 'package:bloom_boom/auth/favorite_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bloom_boom/pages/functionslities/product_detail_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/favorite_model.dart';
import 'dart:math';

class BestDealsWidget extends ConsumerStatefulWidget {
  const BestDealsWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<BestDealsWidget> createState() => _BestDealsWidgetState();
}

class _BestDealsWidgetState extends ConsumerState<BestDealsWidget> {
  List<Map<String, dynamic>> bestDeals = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBestDeals();
  }

  /// Loads 2 RANDOM images from each Firebase Storage flower category
  Future<void> _loadBestDeals() async {
    try {
      print('🔥 Starting to load best deals...');
      List<Map<String, dynamic>> deals = [];
      final random = Random();

      List<Map<String, String>> categories = [
        {'folder': 'yellow_flower', 'name': 'Yellow Flowers'},
        {'folder': 'purple_flower', 'name': 'Purple Flowers'},
        {'folder': 'white_flower', 'name': 'White Flowers'},
        {'folder': 'pink_flower', 'name': 'Pink Flowers'},
      ];

      // Fetch 2 RANDOM images from each category
      for (var category in categories) {
        try {
          print('📂 Checking folder: flowers/${category['folder']}');

          final storageRef = FirebaseStorage.instance
              .ref()
              .child('flowers')
              .child(category['folder']!);

          final listResult = await storageRef.listAll();
          print('✅ Found ${listResult.items.length} items in ${category['folder']}');

          if (listResult.items.isNotEmpty) {
            List<Reference> shuffledItems = List.from(listResult.items)..shuffle(random);
            int itemsToTake = shuffledItems.length >= 2 ? 2 : shuffledItems.length;
            
            for (int i = 0; i < itemsToTake; i++) {
              try {
                final imageUrl = await shuffledItems[i].getDownloadURL();
                print('🖼️ Got URL ${i + 1}: $imageUrl');

                // Create unique product ID
                final productId = '${category['folder']}_deal_$i';

                deals.add({
                  'id': productId,
                  'imageUrl': imageUrl,
                  'productName': category['name']!,
                  'categoryName': category['name']!,
                  'discount': '35% Off',
                });
              } catch (e) {
                print('❌ Error getting download URL: $e');
              }
            }
          } else {
            print('⚠️ No items found in ${category['folder']}');
          }
        } catch (e) {
          print('❌ Error loading ${category['folder']}: $e');
        }
      }

      print('✅ Total deals loaded: ${deals.length}');

      if (mounted) {
        setState(() {
          bestDeals = deals;
          isLoading = false;
          errorMessage = deals.isEmpty ? 'No products found in Firebase Storage' : null;
        });
      }
    } catch (e) {
      print('❌ Fatal error loading best deals: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Best Deals',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),

          // Content - Loading, Error, or Grid
          isLoading
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(color: Color(0xFF079A3D)),
                  ),
                )
              : errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Icon(Icons.error_outline, size: 50, color: Colors.red),
                            SizedBox(height: 8),
                            Text(
                              'Error loading deals',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isLoading = true;
                                  errorMessage = null;
                                });
                                _loadBestDeals();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF079A3D),
                              ),
                              child: Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : bestDeals.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Column(
                              children: [
                                Icon(Icons.local_offer_outlined,
                                    size: 50, color: Colors.grey.shade400),
                                SizedBox(height: 8),
                                Text(
                                  'No deals available',
                                  style: TextStyle(
                                      color: Colors.grey.shade600, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: bestDeals.length,
                          itemBuilder: (context, index) {
                            final deal = bestDeals[index];
                            return _buildDealCard(
                              context,
                              productId: deal['id'],
                              imageUrl: deal['imageUrl'],
                              productName: deal['productName'],
                              categoryName: deal['categoryName'],
                              discount: deal['discount'],
                            );
                          },
                        ),
        ],
      ),
    );
  }

  /// Builds a single deal card with image, discount badge, and favorite icon
  Widget _buildDealCard(
    BuildContext context, {
    required String productId,
    required String imageUrl,
    required String productName,
    required String categoryName,
    required String discount,
  }) {
    final isFav = ref.read(favoriteProvider.notifier).isFavorite(productId);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              imageUrl: imageUrl,
              productName: productName,
              categoryName: categoryName,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    color: Color(0xFFF5F5F5),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF079A3D),
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) {
                        print('Image error: $error');
                        return Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 40,
                        );
                      },
                    ),
                  ),
                ),

                // Discount Badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFF079A3D),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      discount,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Favorite Icon with Real Functionality
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      final fav = FavoriteModel(
                        id: productId,
                        productName: productName,
                        categoryName: categoryName,
                        imageUrl: imageUrl,
                        price: 100.0,
                        addedAt: DateTime.now(),
                      );
                      ref.read(favoriteProvider.notifier).toggleFavorite(fav);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFav ? 'Removed from favorites' : 'Added to favorites',
                          ),
                          backgroundColor: Color(0xFF079A3D),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : Colors.grey.shade600,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '₹100',
                    style: TextStyle(
                      color: Color(0xFF079A3D),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
