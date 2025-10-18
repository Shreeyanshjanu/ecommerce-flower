import 'package:firebase_storage/firebase_storage.dart';
import '../models/flower_model.dart';
import '../services/flower_service.dart';

class FlowerPopulator {
  final FlowerService _flowerService = FlowerService();

  /// Populate Firestore with sample flowers
  /// Call this method ONCE from your app
  Future<void> populateFlowers() async {
    print('🌸 Starting to populate flowers...');

    try {
      // Get all images from Firebase Storage
      final storage = FirebaseStorage.instance;

      // Define categories and their sample flower names
      final Map<String, List<Map<String, dynamic>>> categoryFlowers = {
        'yellow_flower': [
          {
            'name': 'Sunflower Bouquet',
            'description': 'Bright and cheerful sunflowers perfect for bringing sunshine into any space. Fresh, vibrant, and long-lasting blooms.',
            'price': 250.0,
            'rating': 4.7,
            'hasDiscount': true,
            'discountPercentage': 35,
          },
          {
            'name': 'Yellow Rose Delight',
            'description': 'Elegant yellow roses symbolizing friendship and joy. Carefully arranged to create a stunning display.',
            'price': 300.0,
            'rating': 4.6,
            'hasDiscount': true,
            'discountPercentage': 35,
          },
          {
            'name': 'Golden Marigold Bunch',
            'description': 'Traditional golden marigolds perfect for celebrations and religious ceremonies. Fresh and fragrant.',
            'price': 150.0,
            'rating': 4.4,
            'hasDiscount': false,
            'discountPercentage': 0,
          },
        ],
        'purple_flower': [
          {
            'name': 'Purple Lavender Bundle',
            'description': 'Aromatic lavender flowers perfect for relaxation and decoration. Long stems with multiple blooms.',
            'price': 280.0,
            'rating': 4.8,
            'hasDiscount': true,
            'discountPercentage': 35,
          },
          {
            'name': 'Violet Orchid Beauty',
            'description': 'Exotic purple orchids that add elegance to any setting. Premium quality with delicate petals.',
            'price': 450.0,
            'rating': 4.9,
            'hasDiscount': false,
            'discountPercentage': 0,
          },
          {
            'name': 'Purple Iris Garden',
            'description': 'Stunning purple iris flowers with unique patterns. Perfect for sophisticated floral arrangements.',
            'price': 320.0,
            'rating': 4.5,
            'hasDiscount': true,
            'discountPercentage': 35,
          },
        ],
        'pink_flower': [
          {
            'name': 'Pink Rose Garden',
            'description': 'Fresh and romantic pink roses perfect for expressing love and affection. Premium quality blooms.',
            'price': 350.0,
            'rating': 4.9,
            'hasDiscount': true,
            'discountPercentage': 35,
          },
          {
            'name': 'Pink Tulip Collection',
            'description': 'Beautiful pink tulips that bring elegance and grace. Perfect for decorating your home.',
            'price': 280.0,
            'rating': 4.6,
            'hasDiscount': true,
            'discountPercentage': 35,
          },
          {
            'name': 'Pink Carnation Bunch',
            'description': 'Delicate pink carnations symbolizing gratitude and love. Long-lasting and fragrant blooms.',
            'price': 200.0,
            'rating': 4.4,
            'hasDiscount': false,
            'discountPercentage': 0,
          },
        ],
        'white_flower': [
          {
            'name': 'White Orchid Arrangement',
            'description': 'Pure white orchids representing elegance and sophistication. Perfect for weddings and special occasions.',
            'price': 500.0,
            'rating': 4.9,
            'hasDiscount': false,
            'discountPercentage': 0,
          },
          {
            'name': 'White Rose Elegance',
            'description': 'Classic white roses symbolizing purity and new beginnings. Timeless beauty for any occasion.',
            'price': 350.0,
            'rating': 4.7,
            'hasDiscount': true,
            'discountPercentage': 35,
          },
          {
            'name': 'White Lily Bouquet',
            'description': 'Fragrant white lilies with large blooms. Perfect for expressing sympathy and remembrance.',
            'price': 320.0,
            'rating': 4.6,
            'hasDiscount': true,
            'discountPercentage': 35,
          },
        ],
      };

      // Loop through each category
      for (var entry in categoryFlowers.entries) {
        final category = entry.key;
        final flowersList = entry.value;

        print('📂 Processing category: $category');

        // Get images from Firebase Storage for this category
        final storageRef = storage.ref('flowers/$category');
        final listResult = await storageRef.listAll();

        // Add flowers with real image URLs
        for (int i = 0; i < flowersList.length && i < listResult.items.length; i++) {
          final flowerData = flowersList[i];
          final imageUrl = await listResult.items[i].getDownloadURL();

          final flower = FlowerModel(
            id: '', // Auto-generated by Firestore
            name: flowerData['name'],
            description: flowerData['description'],
            category: category,
            occasion: '', // Empty for regular flowers
            imageUrl: imageUrl,
            price: flowerData['price'],
            rating: flowerData['rating'],
            weight: '1 Kg',
            hasDiscount: flowerData['hasDiscount'],
            discountPercentage: flowerData['discountPercentage'],
            isInStock: true,
            createdAt: DateTime.now(),
          );

          await _flowerService.addFlower(flower);
          print('✅ Added: ${flower.name}');
        }
      }

      print('🎉 Flower population completed!');
    } catch (e) {
      print('❌ Error populating flowers: $e');
    }
  }

  /// Populate occasion-based flowers
  Future<void> populateOccasionFlowers() async {
    print('🎊 Starting to populate occasion flowers...');

    try {
      final storage = FirebaseStorage.instance;

      // Define occasions and sample flowers
      final Map<String, List<Map<String, dynamic>>> occasionFlowers = {
        'anniversary': [
          {
            'name': 'Anniversary Rose Bouquet',
            'description': 'Romantic mixed roses perfect for celebrating your special day together. Premium quality blooms.',
            'price': 400.0,
            'rating': 4.9,
          },
          {
            'name': 'Love & Romance Bundle',
            'description': 'Exquisite arrangement of red and white roses symbolizing eternal love and commitment.',
            'price': 450.0,
            'rating': 4.8,
          },
        ],
        'birthday': [
          {
            'name': 'Birthday Celebration Mix',
            'description': 'Colorful mixed flowers to brighten up birthday celebrations. Vibrant and cheerful arrangement.',
            'price': 300.0,
            'rating': 4.7,
          },
          {
            'name': 'Happy Birthday Bouquet',
            'description': 'Festive flower arrangement perfect for making birthdays extra special.',
            'price': 350.0,
            'rating': 4.6,
          },
        ],
        'corporate': [
          {
            'name': 'Corporate Elegance',
            'description': 'Sophisticated floral arrangement perfect for office spaces and corporate events.',
            'price': 500.0,
            'rating': 4.8,
          },
        ],
        'graduation': [
          {
            'name': 'Graduation Success Bouquet',
            'description': 'Celebrate achievements with this proud and elegant flower arrangement.',
            'price': 280.0,
            'rating': 4.5,
          },
        ],
        'sympathy': [
          {
            'name': 'Sympathy White Lilies',
            'description': 'Peaceful white lilies to express condolences and remembrance.',
            'price': 380.0,
            'rating': 4.7,
          },
        ],
        'wedding_romance': [
          {
            'name': 'Wedding Bliss Arrangement',
            'description': 'Stunning bridal flowers perfect for your special day. Romantic and elegant.',
            'price': 600.0,
            'rating': 5.0,
          },
        ],
      };

      // Loop through each occasion
      for (var entry in occasionFlowers.entries) {
        final occasion = entry.key;
        final flowersList = entry.value;

        print('🎉 Processing occasion: $occasion');

        // Get images from Firebase Storage
        final storageRef = storage.ref('occasions/$occasion');
        final listResult = await storageRef.listAll();

        // Add flowers with real image URLs
        for (int i = 0; i < flowersList.length && i < listResult.items.length; i++) {
          final flowerData = flowersList[i];
          final imageUrl = await listResult.items[i].getDownloadURL();

          final flower = FlowerModel(
            id: '', // Auto-generated
            name: flowerData['name'],
            description: flowerData['description'],
            category: '', // Empty for occasion flowers
            occasion: occasion,
            imageUrl: imageUrl,
            price: flowerData['price'],
            rating: flowerData['rating'],
            weight: '1 Kg',
            hasDiscount: false,
            discountPercentage: 0,
            isInStock: true,
            createdAt: DateTime.now(),
          );

          await _flowerService.addFlower(flower);
          print('✅ Added occasion flower: ${flower.name}');
        }
      }

      print('🎉 Occasion flower population completed!');
    } catch (e) {
      print('❌ Error populating occasion flowers: $e');
    }
  }
}
