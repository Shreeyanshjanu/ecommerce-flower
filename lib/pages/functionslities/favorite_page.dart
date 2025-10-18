import 'package:bloom_boom/auth/cart_provider.dart';
import 'package:bloom_boom/auth/favorite_provider.dart';
import 'package:bloom_boom/models/cart_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/favorite_model.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteProvider);

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
          'My Favorites',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          if (favorites.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep, color: Colors.red),
              onPressed: () => _showClearAllDialog(context, ref),
            ),
        ],
      ),
      body: favorites.isEmpty
          ? _buildEmptyState(context)
          : GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.68,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final fav = favorites[index];
                return _buildFavoriteCard(context, ref, fav);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 100, color: Colors.grey.shade300),
          SizedBox(height: 16),
          Text(
            'No Favorites Yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start adding flowers you love!',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF079A3D),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Browse Products',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(
    BuildContext context,
    WidgetRef ref,
    FavoriteModel fav,
  ) {
    return Container(
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
            // <-- Add Expanded here to prevent overflow
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child: CachedNetworkImage(
                    imageUrl: fav.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade200,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF079A3D),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade200,
                      child: Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                ),
                // Remove Favorite Button
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
                      icon: Icon(Icons.favorite, color: Colors.red, size: 20),
                      onPressed: () {
                        ref
                            .read(favoriteProvider.notifier)
                            .removeFavorite(fav.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${fav.productName} removed from favorites',
                            ),
                            backgroundColor: Colors.red,
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
          // Product Details
          Padding(
            padding: const EdgeInsets.all(
              10.0,
            ), // <-- Reduced padding from 12 to 10
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // <-- Add this
              children: [
                // Product Name
                Text(
                  fav.productName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13, // <-- Reduced from 14
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3), // <-- Reduced from 4
                // Category
                Text(
                  fav.categoryName,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11, // <-- Reduced from 12
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6), // <-- Reduced from 8
                // Price
                Text(
                  '₹${fav.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF079A3D),
                    fontSize: 15, // <-- Reduced from 16
                  ),
                ),
                SizedBox(height: 8), // <-- Reduced from 10
                // Add to Cart Button
                SizedBox(
                  width: double.infinity,
                  height: 32, // <-- Reduced from 36
                  child: ElevatedButton(
                    onPressed: () => _addToCart(context, ref, fav),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow.shade700,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 6), // <-- Reduced
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Add to Cart',
                      style: TextStyle(
                        fontSize: 12, // <-- Reduced from 13
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(BuildContext context, WidgetRef ref, FavoriteModel fav) {
    final cartItem = CartItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imageUrl: fav.imageUrl,
      productName: fav.productName,
      categoryName: fav.categoryName,
      price: fav.price,
    );

    ref.read(cartProvider.notifier).addItem(cartItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${fav.productName} added to cart!'),
        backgroundColor: Color(0xFF079A3D),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Favorites'),
        content: Text('Are you sure you want to remove all favorites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(favoriteProvider.notifier).clearFavorites();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All favorites cleared!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
