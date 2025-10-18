import 'package:bloom_boom/models/address_model.dart';
import 'package:bloom_boom/models/cart_model.dart';
import 'package:bloom_boom/models/order_model.dart';
import 'package:bloom_boom/pages/drawer%20pages/location_page.dart';
import 'package:bloom_boom/pages/orders/order_confirmation_page.dart';
import 'package:bloom_boom/auth/cart_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  final List<CartItem> cartItems;
  final double totalAmount;

  const CheckoutPage({
    Key? key,
    required this.cartItems,
    required this.totalAmount,
  }) : super(key: key);

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AddressModel? _selectedAddress;
  String _selectedPaymentMethod = 'COD';
  DateTime _selectedDeliveryDate = DateTime.now().add(Duration(days: 2));
  final TextEditingController _instructionsController = TextEditingController();

  bool _isLoadingAddresses = true;
  bool _isPlacingOrder = false;
  List<AddressModel> _addresses = [];

  final double _deliveryFee = 50.0;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _loadAddresses() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .get();

      setState(() {
        _addresses = snapshot.docs
            .map((doc) => AddressModel.fromMap(doc.data(), doc.id))
            .toList();
        
        // Select first address by default
        if (_addresses.isNotEmpty) {
          _selectedAddress = _addresses.first;
        }
        
        _isLoadingAddresses = false;
      });
    } catch (e) {
      print('Error loading addresses: $e');
      setState(() => _isLoadingAddresses = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Checkout',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoadingAddresses
          ? Center(child: CircularProgressIndicator(color: Color(0xFF079A3D)))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Delivery Address Section
                  _buildSectionTitle('📍 Delivery Address'),
                  SizedBox(height: 12),
                  _buildAddressCard(),
                  SizedBox(height: 24),

                  // Order Summary Section
                  _buildSectionTitle('📦 Order Summary'),
                  SizedBox(height: 12),
                  _buildOrderSummary(),
                  SizedBox(height: 24),

                  // Delivery Date Section
                  _buildSectionTitle('📅 Delivery Date'),
                  SizedBox(height: 12),
                  _buildDeliveryDatePicker(),
                  SizedBox(height: 24),

                  // Special Instructions Section
                  _buildSectionTitle('📝 Special Instructions (Optional)'),
                  SizedBox(height: 12),
                  _buildInstructionsField(),
                  SizedBox(height: 24),

                  // Payment Method Section
                  _buildSectionTitle('💳 Payment Method'),
                  SizedBox(height: 12),
                  _buildPaymentMethods(),
                  SizedBox(height: 24),

                  // Price Details Section
                  _buildSectionTitle('💰 Price Details'),
                  SizedBox(height: 12),
                  _buildPriceDetails(),
                  SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
      bottomNavigationBar: _buildPlaceOrderButton(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildAddressCard() {
    if (_addresses.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(Icons.location_off, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'No delivery address found',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LocationPage()),
                );
                _loadAddresses();
              },
              icon: Icon(Icons.add),
              label: Text('Add Address'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF079A3D),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF079A3D), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFF079A3D).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _selectedAddress!.label,
                  style: TextStyle(
                    color: Color(0xFF079A3D),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: _showAddressSelectionDialog,
                child: Text(
                  'Change',
                  style: TextStyle(color: Color(0xFF079A3D)),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            _selectedAddress!.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            _selectedAddress!.addressLine,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
              SizedBox(width: 4),
              Text(
                _selectedAddress!.phone,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: widget.cartItems.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Qty: ${item.quantity}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${item.totalPrice.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF079A3D),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDeliveryDatePicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDeliveryDate,
          firstDate: DateTime.now().add(Duration(days: 1)),
          lastDate: DateTime.now().add(Duration(days: 30)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(primary: Color(0xFF079A3D)),
              ),
              child: child!,
            );
          },
        );
        
        if (picked != null) {
          setState(() => _selectedDeliveryDate = picked);
        }
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Color(0xFF079A3D)),
            SizedBox(width: 12),
            Text(
              DateFormat('EEEE, MMM d, yyyy').format(_selectedDeliveryDate),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsField() {
    return TextField(
      controller: _instructionsController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'E.g., Ring the doorbell twice, Leave at door',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF079A3D), width: 2),
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      children: [
        _buildPaymentOption(
          'Cash on Delivery',
          'COD',
          Icons.money,
        ),
        SizedBox(height: 12),
        _buildPaymentOption(
          'Virtual Money',
          'Virtual',
          Icons.account_balance_wallet,
        ),
      ],
    );
  }

  Widget _buildPaymentOption(String title, String value, IconData icon) {
    final isSelected = _selectedPaymentMethod == value;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF079A3D).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Color(0xFF079A3D) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Color(0xFF079A3D) : Colors.grey.shade600,
            ),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Color(0xFF079A3D) : Colors.black87,
              ),
            ),
            Spacer(),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Color(0xFF079A3D) : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceDetails() {
    final total = widget.totalAmount + _deliveryFee;
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildPriceRow('Subtotal', widget.totalAmount),
          SizedBox(height: 8),
          _buildPriceRow('Delivery Fee', _deliveryFee),
          Divider(height: 24),
          _buildPriceRow('Total', total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black87 : Colors.grey.shade700,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: isTotal ? Color(0xFF079A3D) : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceOrderButton() {
    return Container(
      padding: EdgeInsets.all(16),
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
      child: ElevatedButton(
        onPressed: _isPlacingOrder ? null : _placeOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF079A3D),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isPlacingOrder
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Place Order - ₹${(widget.totalAmount + _deliveryFee).toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  void _showAddressSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Delivery Address'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _addresses.length,
            itemBuilder: (context, index) {
              final address = _addresses[index];
              return ListTile(
                leading: Icon(
                  Icons.location_on,
                  color: _selectedAddress?.id == address.id
                      ? Color(0xFF079A3D)
                      : Colors.grey,
                ),
                title: Text(address.label),
                subtitle: Text(address.addressLine),
                onTap: () {
                  setState(() => _selectedAddress = address);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LocationPage()),
              );
              _loadAddresses();
            },
            child: Text('Add New Address'),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a delivery address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      final userId = _auth.currentUser!.uid;
      final orderId = DateTime.now().millisecondsSinceEpoch.toString();
      final orderNumber = OrderModel.generateOrderNumber();

      final order = OrderModel(
        id: orderId,
        orderNumber: orderNumber,
        userId: userId,
        items: widget.cartItems,
        deliveryAddress: _selectedAddress!,
        deliveryDate: DateFormat('yyyy-MM-dd').format(_selectedDeliveryDate),
        specialInstructions: _instructionsController.text.trim().isEmpty
            ? null
            : _instructionsController.text.trim(),
        paymentMethod: _selectedPaymentMethod,
        subtotal: widget.totalAmount,
        deliveryFee: _deliveryFee,
        totalAmount: widget.totalAmount + _deliveryFee,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save order to Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc(orderId)
          .set(order.toMap());

      // Clear cart
      await ref.read(cartProvider.notifier).clearCart();

      setState(() => _isPlacingOrder = false);

      // Navigate to confirmation page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderConfirmationPage(order: order),
        ),
      );
    } catch (e) {
      print('Error placing order: $e');
      setState(() => _isPlacingOrder = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error placing order. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
