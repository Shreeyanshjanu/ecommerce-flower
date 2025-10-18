import 'package:bloom_boom/pages/functionslities/ocassion_products_page.dart';
import 'package:flutter/material.dart';

class OccasionWidget extends StatelessWidget {
  const OccasionWidget({Key? key}) : super(key: key);

  // Define your 6 occasions with their Firebase Storage folder names and image paths
  final List<Map<String, String>> occasions = const [
    {
      'name': 'Anniversary',
      'folder': 'anniversary',
      'image': 'assets/images/anniversary.png',
    },
    {
      'name': 'Birthday',
      'folder': 'birthday',
      'image': 'assets/images/birthday.png',
    },
    {
      'name': 'Corporate',
      'folder': 'corporate',
      'image': 'assets/images/corporate.png',
    },
    {
      'name': 'Graduation',
      'folder': 'graduation',
      'image': 'assets/images/graduation.png',
    },
    {
      'name': 'Sympathy',
      'folder': 'sympathy',
      'image': 'assets/images/sympathy.png',
    },
    {
      'name': 'Wedding & Romance',
      'folder': 'wedding_romance',
      'image': 'assets/images/wedding_romance.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shop by Occasion',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              Icon(Icons.celebration, color: Color(0xFF079A3D)),
            ],
          ),
          SizedBox(height: 16),

          // Grid of 6 occasion cards (2 per row)
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85, // Adjusted for image display
            ),
            itemCount: occasions.length,
            itemBuilder: (context, index) {
              final occasion = occasions[index];
              return _buildOccasionCard(
                context,
                name: occasion['name']!,
                folder: occasion['folder']!,
                imagePath: occasion['image']!,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOccasionCard(
    BuildContext context, {
    required String name,
    required String folder,
    required String imagePath,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OccasionProductsPage(
              occasionName: name,
              occasionFolder: folder,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Color(0xFF079A3D).withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image section
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Color(0xFF079A3D).withOpacity(0.1),
                      child: Icon(
                        Icons.celebration,
                        size: 48,
                        color: Color(0xFF079A3D),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Text section
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
