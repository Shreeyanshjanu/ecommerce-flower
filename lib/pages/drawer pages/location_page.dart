import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bloom_boom/models/address_model.dart';
import 'package:lottie/lottie.dart';

class LocationPage extends ConsumerStatefulWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends ConsumerState<LocationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressLineController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  String selectedLabel = 'Home';
  bool _showAddForm = false;
  bool _isLoading = true;
  List<AddressModel> _savedAddresses = [];
  String? _editingAddressId;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressLineController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  /// Load addresses from Firestore
  Future<void> _loadAddresses() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        _savedAddresses = snapshot.docs
            .map((doc) => AddressModel.fromMap(doc.data(), doc.id))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading addresses: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 238, 238, 242),
              Color.fromARGB(255, 235, 231, 237),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.white))
              : Column(
                  children: [
                    // Rotating Flower Animation at the top
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Lottie.asset(
                        'assets/animations/login_button_animation.json',
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Main content
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(20),
                          child: _showAddForm || _savedAddresses.isEmpty
                              ? _buildAddAddressForm()
                              : _buildSavedAddressesList(),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  /// Build list of saved addresses
  Widget _buildSavedAddressesList() {
    return Container(
      constraints: BoxConstraints(maxWidth: 400),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Saved Addresses',
            style: TextStyle(
              fontSize: 26,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),

          ...List.generate(_savedAddresses.length, (index) {
            final address = _savedAddresses[index];
            return _buildAddressCard(address);
          }),

          SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                _clearForm();
                setState(() => _showAddForm = true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5C6BC0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: Text(
                '+ Add New Address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual address card
  Widget _buildAddressCard(AddressModel address) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF5C6BC0).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  address.label,
                  style: TextStyle(
                    color: Color(0xFF5C6BC0),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: Color(0xFF5C6BC0),
                      size: 20,
                    ),
                    onPressed: () => _editAddress(address),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                  SizedBox(width: 12),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    onPressed: () => _deleteAddress(address.id),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),

          Text(
            address.name,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),

          Row(
            children: [
              Icon(Icons.phone_outlined, color: Colors.grey[600], size: 16),
              SizedBox(width: 6),
              Text(
                address.phone,
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 6),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Colors.grey[600],
                size: 16,
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  address.addressLine,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build add address form
  Widget _buildAddAddressForm() {
    return Container(
      constraints: BoxConstraints(maxWidth: 400),
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _editingAddressId != null ? 'Edit Address' : 'Add New Address',
              style: TextStyle(
                fontSize: 26,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 25),

            // Label Selection (Home/Work/Other)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLabelChip('Home'),
                SizedBox(width: 12),
                _buildLabelChip('Work'),
                SizedBox(width: 12),
                _buildLabelChip('Other'),
              ],
            ),
            SizedBox(height: 20),

            // Recipient Name
            _buildTextField(
              controller: _nameController,
              icon: Icons.person_outline,
              hintText: 'Recipient Name',
            ),
            SizedBox(height: 16),

            // Phone Number
            _buildTextField(
              controller: _phoneController,
              icon: Icons.phone_outlined,
              hintText: 'Phone Number',
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),

            // Full Address
            _buildTextField(
              controller: _addressLineController,
              icon: Icons.location_on_outlined,
              hintText: 'Full Address',
              maxLines: 3,
            ),
            SizedBox(height: 16),

            // Latitude and Longitude
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _latitudeController,
                    icon: Icons.pin_drop_outlined,
                    hintText: 'Latitude',
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _longitudeController,
                    icon: Icons.pin_drop_outlined,
                    hintText: 'Longitude',
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 25),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5C6BC0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _editingAddressId != null ? 'Update Address' : 'Save Address',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),

            if (_savedAddresses.isNotEmpty)
              TextButton(
                onPressed: () {
                  _clearForm();
                  setState(() => _showAddForm = false);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFF5C6BC0), fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(fontSize: 15),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
        filled: true,
        fillColor: Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        return null;
      },
    );
  }

  Widget _buildLabelChip(String label) {
    bool isSelected = selectedLabel == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLabel = label;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF5C6BC0) : Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Color(0xFF5C6BC0) : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _clearForm() {
    _nameController.clear();
    _phoneController.clear();
    _addressLineController.clear();
    _latitudeController.clear();
    _longitudeController.clear();
    selectedLabel = 'Home';
    _editingAddressId = null;
  }

  /// Edit address
  void _editAddress(AddressModel address) {
    selectedLabel = address.label;
    _nameController.text = address.name;
    _phoneController.text = address.phone;
    _addressLineController.text = address.addressLine;
    _latitudeController.text = address.latitude?.toString() ?? '';
    _longitudeController.text = address.longitude?.toString() ?? '';
    _editingAddressId = address.id;

    setState(() => _showAddForm = true);
  }

  /// Delete address from Firestore
  Future<void> _deleteAddress(String addressId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Delete Address'),
        content: Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .doc(addressId)
          .delete();

      await _loadAddresses();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Address deleted successfully'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error deleting address: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting address'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Save address to Firestore
  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please login first'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final addressId =
          _editingAddressId ?? DateTime.now().millisecondsSinceEpoch.toString();

      final address = AddressModel(
        id: addressId,
        label: selectedLabel,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        addressLine: _addressLineController.text.trim(),
        latitude: double.tryParse(_latitudeController.text.trim()),
        longitude: double.tryParse(_longitudeController.text.trim()),
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .doc(address.id)
          .set(address.toMap());

      _clearForm();
      await _loadAddresses();

      setState(() => _showAddForm = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _editingAddressId != null
                  ? 'Address updated successfully!'
                  : 'Address saved successfully!',
            ),
            backgroundColor: Color(0xFF5C6BC0),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error saving address: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving address'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
