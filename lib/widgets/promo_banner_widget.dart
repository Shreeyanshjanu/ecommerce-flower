import 'package:flutter/material.dart';
import 'package:bloom_boom/pages/functionslities/category_page.dart';
import 'dart:async';

class PromoBannerWidget extends StatefulWidget {
  const PromoBannerWidget({Key? key}) : super(key: key);

  @override
  State<PromoBannerWidget> createState() => _PromoBannerWidgetState();
}

class _PromoBannerWidgetState extends State<PromoBannerWidget> {
  final List<Map<String, dynamic>> bannerData = [
    {
      'title': 'Yellow Flowers',
      'subtitle': 'Brighten your day with sunshine blooms',
      'buttonText': 'Shop Now',
      'imageType': 'asset',
      'imagePath': 'assets/images/yellow_flower.jpg',
      'folder': 'yellow_flower',
      'categoryName': 'Yellow Flowers',
    },
    {
      'title': 'Purple Flowers',
      'subtitle': 'Elegant purple blooms for any occasion',
      'buttonText': 'Explore',
      'imageType': 'asset',
      'imagePath': 'assets/images/purple_flower.jpg',
      'folder': 'purple_flower',
      'categoryName': 'Purple Flowers',
    },
    {
      'title': 'White Flowers',
      'subtitle': 'Pure and pristine white blossoms',
      'buttonText': 'View All',
      'imageType': 'asset',
      'imagePath': 'assets/images/white_flower.jpg',
      'folder': 'white_flower',
      'categoryName': 'White Flowers',
    },
    {
      'title': 'Pink Flowers',
      'subtitle': 'Romantic pink petals for special moments',
      'buttonText': 'Discover',
      'imageType': 'asset',
      'imagePath': 'assets/images/pink_flower.jpg',
      'folder': 'pink_flower',
      'categoryName': 'Pink Flowers',
    },
  ];

  int currentPage = 0;
  late PageController _pageController;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  /// Auto-scroll every 2 seconds
  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (currentPage + 1) % bannerData.length;

        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // PageView with auto-scroll
        Container(
          height: 150,
          child: PageView.builder(
            controller: _pageController,
            itemCount: bannerData.length,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildBannerCard(bannerData[index]);
            },
          ),
        ),

        // Page indicators
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            bannerData.length,
            (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              width: currentPage == index ? 12 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: currentPage == index
                    ? Color(0xFF079A3D)
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerCard(Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () {
        // Navigate to CategoryPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryPage(
              categoryFolder: data['folder']!,
              categoryName: data['categoryName']!,
              categoryImage: data['imagePath']!,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left side: Text and button (3/4 of space)
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      data['title']!,
                      style: TextStyle(
                        color: Color(0xFF079A3D),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6),
                    Text(
                      data['subtitle']!,
                      style: TextStyle(fontSize: 11, color: Colors.black54),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 100.0,
                      height: 35.0,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to CategoryPage
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryPage(
                                categoryFolder: data['folder']!,
                                categoryName: data['categoryName']!,
                                categoryImage: data['imagePath']!,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF079A3D),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          data['buttonText']!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Right side: Flower Image (1/4 of space)
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    data['imagePath']!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.local_florist,
                        size: 60,
                        color: Colors.grey,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
