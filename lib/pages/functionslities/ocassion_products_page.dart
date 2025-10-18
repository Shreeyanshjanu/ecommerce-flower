import 'package:bloom_boom/auth/favorite_provider.dart';
import 'package:bloom_boom/models/favorite_model.dart';
import 'package:bloom_boom/pages/functionslities/product_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OccasionProductsPage extends ConsumerStatefulWidget {
  final String occasionName;
  final String occasionFolder;

  const OccasionProductsPage({
    Key? key,
    required this.occasionName,
    required this.occasionFolder,
  }) : super(key: key);

  @override
  ConsumerState<OccasionProductsPage> createState() => _OccasionProductsPageState();
}

class _OccasionProductsPageState extends ConsumerState<OccasionProductsPage> {
  List<String> flowerImages = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOccasionFlowers();
  }

  Future<void> _loadOccasionFlowers() async {
    try {
      print('📂 Loading flowers from: occasions/${widget.occasionFolder}');

      final storageRef = FirebaseStorage.instance.ref('occasions/${widget.occasionFolder}');
      final listResult = await storageRef.listAll();

      print('✅ Found ${listResult.items.length} items');

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
      print('❌ Error loading images: $e');
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
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
          widget.occasionName,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: Color(0xFF079A3D)),
            )
          : errorMessage != null
              ? _buildErrorState()
              : flowerImages.isEmpty
                  ? _buildEmptyState()
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
    final productId = '${widget.occasionFolder}_${index + 1}';
    final productName = '${widget.occasionName} Flower ${index + 1}';

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
                  categoryName: widget.occasionName,
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
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF079A3D),
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        ),
                      ),
                      // Heart Icon
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
                                categoryName: widget.occasionName,
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
                          fontSize: 14,
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
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Color(0xFF079A3D),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.add, color: Colors.white, size: 18),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_florist, size: 80, color: Colors.grey.shade300),
          SizedBox(height: 16),
          Text(
            'No flowers available',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          SizedBox(height: 8),
          Text(
            'Check back soon!',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
          SizedBox(height: 16),
          Text(
            'Error loading flowers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                isLoading = true;
                errorMessage = null;
              });
              _loadOccasionFlowers();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF079A3D),
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }
}
