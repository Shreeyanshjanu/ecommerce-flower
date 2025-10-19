import 'package:bloom_boom/pages/drawer%20pages/about_developer_page.dart';
import 'package:bloom_boom/pages/functionslities/favorite_page.dart';
import 'package:bloom_boom/pages/drawer%20pages/location_page.dart';
import 'package:bloom_boom/pages/orders/orders_page.dart';
import 'package:bloom_boom/widgets/best_deal_widget.dart';
import 'package:bloom_boom/widgets/category_widget.dart';
import 'package:bloom_boom/widgets/ocassion_widget.dart';
import 'package:bloom_boom/widgets/promo_banner_widget.dart';
import 'package:bloom_boom/pages/functionslities/add_to_cart_page.dart';
import 'package:flutter/material.dart';
import 'package:bloom_boom/pages/drawer%20pages/settings_page.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bloom_boom/auth/cart_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/drawer_bg.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: ListView(
            children: [
              // Drawer Header
              Container(
                height: 100,
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
                padding: EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Bloom Boom',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Settings Option
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: ListTile(
                  leading: SizedBox(
                    width: 40,
                    height: 40,
                    child: Lottie.asset(
                      'assets/animations/settings.json',
                      repeat: true,
                    ),
                  ),
                  title: Text(
                    'Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SettingsPage()),
                    );
                  },
                ),
              ),
              SizedBox(height: 0),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: ListTile(
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    child: Lottie.asset(
                      'assets/animations/userdetail.json',
                      repeat: true,
                    ),
                  ),
                  title: Text(
                    'About developer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AboutDeveloperPage()),
                    );
                  },
                ),
              ),
              // location page
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: ListTile(
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    child: Lottie.asset(
                      'assets/animations/location.json',
                      repeat: true,
                    ),
                  ),
                  title: Text(
                    'Edit             Location',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LocationPage()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: true,
            pinned: false,
            snap: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                'assets/images/home_header.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: PromoBannerWidget(),
                ),
                SizedBox(height: 20),
                Padding(padding: EdgeInsets.all(16), child: CategoryWidget()),
                SizedBox(height: 20),
                Padding(padding: EdgeInsets.all(16), child: OccasionWidget()),
                SizedBox(height: 20),
                Padding(padding: EdgeInsets.all(16), child: BestDealsWidget()),
                SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar with 3 icons
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 12.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Menu/Drawer Icon
                GestureDetector(
                  onTap: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.menu, size: 28, color: Colors.black87),
                      SizedBox(height: 4),
                      Text(
                        'Menu',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ],
                  ),
                ),

                // Orders Icon
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => OrdersPage()),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 28,
                        color: Colors.black87,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Orders',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                // favorite page icon
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => FavoritesPage()),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite_border_outlined,
                        size: 28,
                        color: Colors.black87,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Favorites',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ],
                  ),
                ),

                // Cart Icon with Badge
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddToCartPage()),
                    );
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 28,
                            color: Colors.black87,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Cart',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      // Badge showing item count
                      if (cartState.itemCount > 0)
                        Positioned(
                          right: -6,
                          top: -4,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              '${cartState.itemCount}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
