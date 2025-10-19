import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/flower_model.dart';
import '../services/flower_service.dart';
import '../services/admin_service.dart';

class AddFlowerPage extends StatefulWidget {
  @override
  _AddFlowerPageState createState() => _AddFlowerPageState();
}

class _AddFlowerPageState extends State<AddFlowerPage> {
  final _formKey = GlobalKey<FormState>();
  final FlowerService _flowerService = FlowerService();

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _newCategoryController = TextEditingController();

  String _selectedCategory = 'pink_flower';
  String _selectedOccasion = '';
  bool _hasDiscount = false;
  int _discountPercentage = 0;
  File? _imageFile;
  bool _isLoading = false;
  bool _isAdmin = false;
  bool _isCheckingAdmin = true;
  bool _isCreatingNewCategory = false; // NEW

  // Base categories list (can be modified dynamically)
  List<String> categories = [
    'pink_flower',
    'purple_flower',
    'yellow_flower',
    'white_flower',
    '+ Create New Category', // NEW option
  ];

  final List<String> occasions = [
    '',
    'anniversary',
    'birthday',
    'corporate',
    'graduation',
    'sympathy',
    'wedding_romance',
  ];

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final isAdmin = await AdminService.isAdmin();

    if (!isAdmin) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('❌ Access denied - Admin only')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    setState(() {
      _isAdmin = true;
      _isCheckingAdmin = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Add New Flower'),
          backgroundColor: Color(0xFF079A3D),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF079A3D)),
              SizedBox(height: 16),
              Text('Verifying admin access...'),
            ],
          ),
        ),
      );
    }

    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Access Denied'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 80, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Access Denied',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Admin privileges required'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.admin_panel_settings, size: 20),
            SizedBox(width: 8),
            Text('Add New Flower'),
          ],
        ),
        backgroundColor: Color(0xFF079A3D),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Admin badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.deepOrange],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'ADMIN MODE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Image picker
              Text(
                'Flower Image *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _imageFile == null
                          ? Colors.red
                          : Color(0xFF079A3D),
                      width: 2,
                    ),
                  ),
                  child: _imageFile == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap to add image',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        ),
                ),
              ),
              SizedBox(height: 24),

              // Name field
              Text(
                'Flower Name *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'e.g., Orange Rose Bouquet',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.local_florist),
                ),
                validator: (v) => v!.isEmpty ? 'Flower name is required' : null,
              ),
              SizedBox(height: 16),

              // Description field
              Text(
                'Description *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Describe the flower...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (v) => v!.isEmpty ? 'Description is required' : null,
              ),
              SizedBox(height: 16),

              // Category dropdown - ENHANCED
              Text(
                'Category *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.category),
                ),
                items: categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Row(
                      children: [
                        if (cat == '+ Create New Category')
                          Icon(
                            Icons.add_circle_outline,
                            color: Color(0xFF079A3D),
                            size: 18,
                          ),
                        if (cat == '+ Create New Category') SizedBox(width: 8),
                        Text(
                          cat == '+ Create New Category'
                              ? cat
                              : cat.replaceAll('_', ' ').toUpperCase(),
                          style: TextStyle(
                            color: cat == '+ Create New Category'
                                ? Color(0xFF079A3D)
                                : Colors.black,
                            fontWeight: cat == '+ Create New Category'
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val == '+ Create New Category') {
                    _showCreateCategoryDialog();
                  } else {
                    setState(() => _selectedCategory = val!);
                  }
                },
              ),
              SizedBox(height: 16),

              // Show new category input if creating
              if (_isCreatingNewCategory) ...[
                Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.add_circle, color: Colors.orange),
                            SizedBox(width: 8),
                            Text(
                              'Creating New Category',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: _newCategoryController,
                          decoration: InputDecoration(
                            labelText: 'Enter category name',
                            hintText: 'e.g., orange_flower',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.edit),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _isCreatingNewCategory = false;
                                  _newCategoryController.clear();
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tip: Use lowercase with underscores (e.g., orange_flower, red_flower)',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],

              // Occasion dropdown
              Text(
                'Occasion (Optional)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedOccasion,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.event),
                ),
                items: occasions.map((occ) {
                  return DropdownMenuItem(
                    value: occ,
                    child: Text(
                      occ.isEmpty
                          ? 'None'
                          : occ.replaceAll('_', ' ').toUpperCase(),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedOccasion = val!),
              ),
              SizedBox(height: 16),

              // Price and Rating in row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price (₹) *',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _priceController,
                          decoration: InputDecoration(
                            labelText: '₹',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.currency_rupee),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rating (1-5) *',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _ratingController,
                          decoration: InputDecoration(
                            labelText: '4.5',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.star),
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (v) {
                            if (v!.isEmpty) return 'Required';
                            final rating = double.tryParse(v);
                            if (rating == null || rating < 1 || rating > 5) {
                              return '1-5 only';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Discount section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    children: [
                      CheckboxListTile(
                        title: Text('Has Discount'),
                        subtitle: Text('Enable discount badge on product'),
                        value: _hasDiscount,
                        onChanged: (val) => setState(() => _hasDiscount = val!),
                        activeColor: Color(0xFF079A3D),
                      ),
                      if (_hasDiscount) ...[
                        SizedBox(height: 8),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Discount Percentage',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.local_offer),
                            suffixText: '%',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (val) =>
                              _discountPercentage = int.tryParse(val) ?? 0,
                          validator: (v) {
                            if (_hasDiscount && (v == null || v.isEmpty)) {
                              return 'Enter discount %';
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _addFlower,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF079A3D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(Icons.add_circle_outline),
                  label: Text(
                    _isLoading ? 'Adding Flower...' : 'Add Flower to Store',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // NEW METHOD - Show dialog to create category
  void _showCreateCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.add_circle, color: Color(0xFF079A3D)),
            SizedBox(width: 8),
            Text('Create New Category'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter a name for the new flower category:'),
            SizedBox(height: 16),
            TextField(
              controller: _newCategoryController,
              decoration: InputDecoration(
                labelText: 'Category Name',
                hintText: 'e.g., orange_flower',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              autofocus: true,
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Tip: Use lowercase with underscores\nExamples:\n• orange_flower\n• red_flower\n• blue_flower',
                style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _newCategoryController.clear();
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newCategory = _newCategoryController.text
                  .trim()
                  .toLowerCase();

              if (newCategory.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a category name')),
                );
                return;
              }

              if (newCategory.contains(' ')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Use underscores instead of spaces')),
                );
                return;
              }

              // Add new category to list
              setState(() {
                categories.insert(categories.length - 1, newCategory);
                _selectedCategory = newCategory;
                _isCreatingNewCategory = true;
              });

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Category "$newCategory" created!'),
                  backgroundColor: Color(0xFF079A3D),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF079A3D)),
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();

      // For desktop/web, use different approach
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });

        print('✅ Image selected: ${pickedFile.path}');
      } else {
        print('❌ No image selected');
      }
    } catch (e) {
      print('❌ Error picking image: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addFlower() async {
    // Use new category if one was created
    final finalCategory =
        _isCreatingNewCategory && _newCategoryController.text.isNotEmpty
        ? _newCategoryController.text.trim().toLowerCase()
        : _selectedCategory;

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Please select an image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Upload image to Firebase Storage with new category
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('flowers')
          .child(finalCategory) // Uses new category or selected one
          .child('$fileName.jpg');

      await storageRef.putFile(_imageFile!);
      final imageUrl = await storageRef.getDownloadURL();

      // Create flower object
      final flower = FlowerModel(
        id: '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: finalCategory,
        occasion: _selectedOccasion,
        imageUrl: imageUrl,
        price: double.parse(_priceController.text),
        rating: double.parse(_ratingController.text),
        weight: '1 Kg',
        hasDiscount: _hasDiscount,
        discountPercentage: _discountPercentage,
        isInStock: true,
        createdAt: DateTime.now(),
      );

      // Add to Firestore
      await _flowerService.addFlower(flower);

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '✅ ${_nameController.text} added to $finalCategory!',
                ),
              ),
            ],
          ),
          backgroundColor: Color(0xFF079A3D),
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _ratingController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }
}
