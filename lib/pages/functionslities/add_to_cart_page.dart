import 'package:bloom_boom/auth/cart_provider.dart';
import 'package:bloom_boom/auth/favorite_provider.dart';
import 'package:bloom_boom/models/cart_model.dart';
import 'package:bloom_boom/models/favorite_model.dart';
import 'package:bloom_boom/pages/functionslities/checkout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AddToCartPage extends ConsumerWidget {
  const AddToCartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Cart',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // Virtual Money Display (Clickable)
          GestureDetector(
            onTap: () {
              _showAddMoneyDialog(context, ref);
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0xFF079A3D).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Color(0xFF079A3D), width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: Color(0xFF079A3D),
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    '₹${cart.virtualMoney.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Color(0xFF079A3D),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey.shade300,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add some products to get started',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return _buildCartItem(context, item, cartNotifier);
                    },
                  ),
                ),
                _buildCheckoutSection(context, cart),
              ],
            ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartItem item,
    CartNotifier cartNotifier,
  ) {
    // Create product ID for favorites
    final productId = item.id;

    return Consumer(
      builder: (context, ref, _) {
        final isFav = ref.read(favoriteProvider.notifier).isFavorite(productId);

        return Container(
          margin: EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  width: 80,
                  height: 80,
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
              SizedBox(width: 12),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.categoryName,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '₹${item.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF079A3D),
                      ),
                    ),
                  ],
                ),
              ),

              // Action Buttons Column
              Column(
                children: [
                  // Heart Icon (Favorite)
                  IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : Colors.grey,
                      size: 20,
                    ),
                    onPressed: () {
                      final fav = FavoriteModel(
                        id: productId,
                        productName: item.productName,
                        categoryName: item.categoryName,
                        imageUrl: item.imageUrl,
                        price: item.price,
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
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                  SizedBox(height: 8),

                  // Delete button
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    onPressed: () {
                      _showRemoveDialog(context, item, cartNotifier);
                    },
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                  SizedBox(height: 12),

                  // Quantity Controls
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFF079A3D).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => cartNotifier.decreaseQuantity(item.id),
                          child: Icon(
                            Icons.remove,
                            size: 16,
                            color: Color(0xFF079A3D),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${item.quantity}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(width: 8),
                        InkWell(
                          onTap: () => cartNotifier.increaseQuantity(item.id),
                          child: Icon(
                            Icons.add,
                            size: 16,
                            color: Color(0xFF079A3D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCheckoutSection(BuildContext context, CartState cart) {
    return Container(
      padding: EdgeInsets.all(20),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Total Items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Items:',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              Text(
                '${cart.items.fold(0, (sum, item) => sum + item.quantity)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Divider(),
          SizedBox(height: 8),
          // Total Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '₹${cart.totalAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF079A3D),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Proceed to Checkout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (cart.totalAmount > cart.virtualMoney) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Insufficient balance! Add more virtual money.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  // Navigate to Checkout Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutPage(
                        cartItems: cart.items, // Pass cart items
                        totalAmount: cart.totalAmount,
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF079A3D),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Proceed to Checkout',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveDialog(
    BuildContext context,
    CartItem item,
    CartNotifier cartNotifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Item'),
        content: Text(
          'Are you sure you want to remove ${item.productName} from cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              cartNotifier.removeItem(item.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item.productName} removed from cart'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddMoneyDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Virtual Money'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add virtual money for testing purposes.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (₹)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.currency_rupee),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                ref.read(cartProvider.notifier).addVirtualMoney(amount);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '₹${amount.toStringAsFixed(0)} added successfully!',
                    ),
                    backgroundColor: Color(0xFF079A3D),
                  ),
                );
              }
            },
            child: Text('Add', style: TextStyle(color: Color(0xFF079A3D))),
          ),
        ],
      ),
    );
  }
}
