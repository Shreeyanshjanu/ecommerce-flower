import 'package:bloom_boom/auth/favorite_provider.dart';
import 'package:bloom_boom/models/favorite_model.dart';
import 'package:bloom_boom/pages/functionslities/product_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryPage extends StatefulWidget {
  final String categoryFolder;
  final String categoryName;
  final String categoryImage;

  const CategoryPage({
    Key? key,
    required this.categoryFolder,
    required this.categoryName,
    required this.categoryImage,
  }) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<String> flowerImages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFlowersFromFirebase();
  }

  Future<void> _loadFlowersFromFirebase() async {
    try {
      final storageRef = FirebaseStorage.instance.ref(
        'flowers/${widget.categoryFolder}',
      );
      final listResult = await storageRef.listAll();

      List<String> urls = [];
      for (var item in listResult.items) {
        final url = await item.getDownloadURL();
        urls.add(url);
      }

      setState(() {
        flowerImages = urls;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading images: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.categoryName,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF079A3D)))
          : flowerImages.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_florist, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No flowers found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: flowerImages.length,
              itemBuilder: (context, index) {
                return _buildProductCard(flowerImages[index], index);
              },
            ),
    );
  }

  Widget _buildProductCard(String imageUrl, int index) {
    // Create a unique product ID
    final productId = '${widget.categoryFolder}_${index + 1}';
    final productName = '${widget.categoryName} ${index + 1}';

    return Consumer(
      builder: (context, ref, _) {
        final isFav = ref.read(favoriteProvider.notifier).isFavorite(productId);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailPage(
                  imageUrl: imageUrl,
                  productName: productName,
                  categoryName: widget.categoryName,
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
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with Heart Icon
                Expanded(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF079A3D),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                      // Heart Icon in top-right corner
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : Colors.grey,
                              size: 20,
                            ),
                            onPressed: () {
                              final fav = FavoriteModel(
                                id: productId,
                                productName: productName,
                                categoryName: widget.categoryName,
                                imageUrl: imageUrl,
                                price: 100.0, // Default price
                                addedAt: DateTime.now(),
                              );
                              ref
                                  .read(favoriteProvider.notifier)
                                  .toggleFavorite(fav);

                              // Show feedback
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isFav
                                        ? 'Removed from favorites'
                                        : 'Added to favorites',
                                  ),
                                  backgroundColor: Color(0xFF079A3D),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            padding: EdgeInsets.all(8),
                            constraints: BoxConstraints(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Details
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹100',
                            style: TextStyle(
                              color: Color(0xFF079A3D),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Color(0xFF079A3D),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
