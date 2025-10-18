import 'package:bloom_boom/widgets/see_all_widget.dart';
import 'package:flutter/material.dart';

class CategoryWidget extends StatefulWidget {
  const CategoryWidget({Key? key}) : super(key: key);

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Category title and See All button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Category',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Show glass popup with all categories
                  SeeAllWidget.show(context); // Fixed: proper method call
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'See All',
                  style: TextStyle(color: Color(0xFF079A3D), fontSize: 14),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Category Items Row - Scrollable horizontally
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                buildCategoryItem(
                  imagePath: 'assets/images/pink_flower.jpg',
                  label: 'Pink Flower',
                  backgroundColor: Color.fromARGB(255, 243, 243, 241),
                  onTap: () => print('Pink flower tapped'),
                ),
                SizedBox(width: 16),
                buildCategoryItem(
                  imagePath: 'assets/images/purple_flower.jpg',
                  label: 'Purple Flower',
                  backgroundColor: const Color.fromARGB(255, 255, 254, 254),
                  onTap: () => print('Purple flower tapped'),
                ),
                SizedBox(width: 16),
                buildCategoryItem(
                  imagePath: 'assets/images/white_flower.jpg',
                  label: 'White Flower',
                  backgroundColor: Color.fromARGB(255, 249, 248, 249),
                  onTap: () => print('White flower tapped'),
                ),
                SizedBox(width: 16),
                buildCategoryItem(
                  imagePath: 'assets/images/yellow_flower.jpg',
                  label: 'Yellow Flower',
                  backgroundColor: Color.fromARGB(255, 254, 254, 255),
                  onTap: () => print('Yellow flower tapped'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single category item with image and label
  Widget buildCategoryItem({
    required String imagePath,
    required String label,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Category Image Container
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: 30,
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 8),

          // Category Label
          Container(
            width: 70,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
