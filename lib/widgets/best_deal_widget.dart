import 'package:bloom_boom/auth/favorite_provider.dart';
import 'package:bloom_boom/auth/flower_provider.dart';
import 'package:bloom_boom/models/favorite_model.dart';
import 'package:bloom_boom/models/flower_model.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bloom_boom/pages/functionslities/product_detail_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BestDealsWidget extends ConsumerWidget {
  const BestDealsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dealsAsync = ref.watch(bestDealsProvider);

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

          // Content
          dealsAsync.when(
            data: (deals) {
              if (deals.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Text(
                      'No deals available',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: deals.length,
                itemBuilder: (context, index) {
                  return _buildDealCard(context, ref, deals[index]);
                },
              );
            },
            loading: () => Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: CircularProgressIndicator(color: Color(0xFF079A3D)),
              ),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Error loading deals',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDealCard(
    BuildContext context,
    WidgetRef ref,
    FlowerModel flower,
  ) {
    final isFav = ref.watch(favoriteProvider.notifier).isFavorite(flower.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              imageUrl: flower.imageUrl,
              productName: flower.name,
              categoryName: flower.category,
              price: flower.price,
              description: flower.description,
              rating: flower.rating,
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
          mainAxisSize: MainAxisSize.min, // Add this line
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
                      imageUrl: flower.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF079A3D),
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
                  ),
                ),

                // Discount Badge
                if (flower.hasDiscount)
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
                        '${flower.discountPercentage}% Off',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Favorite Icon
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      final fav = FavoriteModel(
                        id: flower.id,
                        productName: flower.name,
                        categoryName: flower.category,
                        imageUrl: flower.imageUrl,
                        price: flower.price,
                        addedAt: DateTime.now(),
                      );
                      ref.read(favoriteProvider.notifier).toggleFavorite(fav);

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

            // Product Details - Fixed padding
            Padding(
              padding: const EdgeInsets.all(10.0), // Reduced from 12 to 10
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Add this
                children: [
                  Text(
                    flower.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13, // Reduced from 14 to 13
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2), // Reduced from 4 to 2
                  Text(
                    '₹${flower.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Color(0xFF079A3D),
                      fontWeight: FontWeight.bold,
                      fontSize: 15, // Reduced from 16 to 15
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
