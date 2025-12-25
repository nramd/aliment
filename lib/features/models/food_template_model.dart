import 'package:flutter/material.dart';

class FoodTemplate {
  final String name;
  final String category;
  final int defaultExpiryDays;
  final String defaultUnit;
  final int defaultQuantity;
  final String storageLocation;
  final IconData icon;

  const FoodTemplate({
    required this.name,
    required this. category,
    required this.defaultExpiryDays,
    required this.defaultUnit,
    required this.defaultQuantity,
    required this.storageLocation,
    required this.icon,
  });
}

// Database template makanan dengan smart defaults
class FoodTemplateData {
  static const List<FoodTemplate> templates = [
    // PROTEIN
    FoodTemplate(
      name: 'Dada Ayam',
      category:  'Protein',
      defaultExpiryDays: 3,
      defaultUnit: 'gram',
      defaultQuantity: 500,
      storageLocation:  'Kulkas',
      icon: Icons.kebab_dining,
    ),
    FoodTemplate(
      name: 'Daging Sapi',
      category: 'Protein',
      defaultExpiryDays: 5,
      defaultUnit: 'gram',
      defaultQuantity:  500,
      storageLocation: 'Kulkas',
      icon: Icons.kebab_dining,
    ),
    FoodTemplate(
      name: 'Ikan Segar',
      category: 'Protein',
      defaultExpiryDays: 2,
      defaultUnit: 'gram',
      defaultQuantity:  300,
      storageLocation: 'Kulkas',
      icon: Icons.set_meal,
    ),
    FoodTemplate(
      name:  'Telur Ayam',
      category: 'Protein',
      defaultExpiryDays: 21,
      defaultUnit: 'butir',
      defaultQuantity:  10,
      storageLocation: 'Kulkas',
      icon: Icons.egg,
    ),
    FoodTemplate(
      name: 'Tahu',
      category: 'Protein',
      defaultExpiryDays: 5,
      defaultUnit: 'gram',
      defaultQuantity: 250,
      storageLocation: 'Kulkas',
      icon: Icons.square_rounded,
    ),
    FoodTemplate(
      name: 'Tempe',
      category: 'Protein',
      defaultExpiryDays: 4,
      defaultUnit: 'gram',
      defaultQuantity:  200,
      storageLocation: 'Kulkas',
      icon: Icons.square_rounded,
    ),

    // SAYURAN 
    FoodTemplate(
      name: 'Bayam',
      category: 'Sayuran',
      defaultExpiryDays: 3,
      defaultUnit: 'ikat',
      defaultQuantity:  1,
      storageLocation: 'Kulkas',
      icon:  Icons.eco,
    ),
    FoodTemplate(
      name: 'Kangkung',
      category: 'Sayuran',
      defaultExpiryDays: 3,
      defaultUnit: 'ikat',
      defaultQuantity: 1,
      storageLocation: 'Kulkas',
      icon: Icons.eco,
    ),
    FoodTemplate(
      name: 'Wortel',
      category: 'Sayuran',
      defaultExpiryDays: 14,
      defaultUnit: 'gram',
      defaultQuantity: 500,
      storageLocation: 'Kulkas',
      icon: Icons.eco,
    ),
    FoodTemplate(
      name: 'Brokoli',
      category: 'Sayuran',
      defaultExpiryDays: 7,
      defaultUnit: 'gram',
      defaultQuantity: 300,
      storageLocation: 'Kulkas',
      icon: Icons.eco,
    ),
    FoodTemplate(
      name: 'Tomat',
      category: 'Sayuran',
      defaultExpiryDays: 7,
      defaultUnit: 'buah',
      defaultQuantity:  5,
      storageLocation: 'Kulkas',
      icon: Icons.eco,
    ),
    FoodTemplate(
      name: 'Cabai',
      category: 'Sayuran',
      defaultExpiryDays: 10,
      defaultUnit: 'gram',
      defaultQuantity: 100,
      storageLocation:  'Kulkas',
      icon: Icons.local_fire_department,
    ),

    // BUAH
    FoodTemplate(
      name: 'Pisang',
      category: 'Buah',
      defaultExpiryDays: 5,
      defaultUnit: 'sisir',
      defaultQuantity:  1,
      storageLocation: 'Rak Dapur',
      icon: Icons.breakfast_dining,
    ),
    FoodTemplate(
      name:  'Apel',
      category: 'Buah',
      defaultExpiryDays: 14,
      defaultUnit: 'buah',
      defaultQuantity:  5,
      storageLocation: 'Kulkas',
      icon: Icons. apple,
    ),
    FoodTemplate(
      name: 'Jeruk',
      category:  'Buah',
      defaultExpiryDays: 14,
      defaultUnit: 'buah',
      defaultQuantity: 5,
      storageLocation: 'Kulkas',
      icon: Icons.circle,
    ),
    FoodTemplate(
      name: 'Alpukat',
      category: 'Buah',
      defaultExpiryDays: 5,
      defaultUnit: 'buah',
      defaultQuantity: 3,
      storageLocation: 'Rak Dapur',
      icon: Icons.spa,
    ),
    FoodTemplate(
      name: 'Mangga',
      category:  'Buah',
      defaultExpiryDays: 7,
      defaultUnit: 'buah',
      defaultQuantity: 3,
      storageLocation: 'Kulkas',
      icon: Icons.egg_alt,
    ),

    // DAIRY 
    FoodTemplate(
      name: 'Susu Segar',
      category: 'Dairy',
      defaultExpiryDays: 7,
      defaultUnit: 'liter',
      defaultQuantity:  1,
      storageLocation: 'Kulkas',
      icon: Icons.local_drink,
    ),
    FoodTemplate(
      name: 'Susu UHT',
      category: 'Dairy',
      defaultExpiryDays: 180,
      defaultUnit: 'liter',
      defaultQuantity: 1,
      storageLocation: 'Rak Dapur',
      icon: Icons.local_drink,
    ),
    FoodTemplate(
      name: 'Yogurt',
      category: 'Dairy',
      defaultExpiryDays: 14,
      defaultUnit: 'gram',
      defaultQuantity: 200,
      storageLocation: 'Kulkas',
      icon: Icons.icecream,
    ),
    FoodTemplate(
      name:  'Keju',
      category: 'Dairy',
      defaultExpiryDays:  30,
      defaultUnit:  'gram',
      defaultQuantity: 200,
      storageLocation: 'Kulkas',
      icon: Icons.square,
    ),

    // MAKANAN KALENG
    FoodTemplate(
      name: 'Sarden Kaleng',
      category: 'Makanan Kaleng',
      defaultExpiryDays: 365,
      defaultUnit: 'kaleng',
      defaultQuantity:  1,
      storageLocation: 'Rak Dapur',
      icon: Icons.inventory_2,
    ),
    FoodTemplate(
      name: 'Kornet',
      category: 'Makanan Kaleng',
      defaultExpiryDays: 365,
      defaultUnit: 'kaleng',
      defaultQuantity: 1,
      storageLocation: 'Rak Dapur',
      icon: Icons.inventory_2,
    ),
    FoodTemplate(
      name: 'Kacang Kaleng',
      category: 'Makanan Kaleng',
      defaultExpiryDays:  365,
      defaultUnit:  'kaleng',
      defaultQuantity: 1,
      storageLocation: 'Rak Dapur',
      icon: Icons.inventory_2,
    ),

    // MINUMAN
    FoodTemplate(
      name: 'Jus Buah',
      category: 'Minuman',
      defaultExpiryDays: 7,
      defaultUnit: 'liter',
      defaultQuantity:  1,
      storageLocation: 'Kulkas',
      icon: Icons.local_cafe,
    ),
    FoodTemplate(
      name: 'Air Mineral',
      category: 'Minuman',
      defaultExpiryDays: 365,
      defaultUnit: 'liter',
      defaultQuantity: 1,
      storageLocation: 'Rak Dapur',
      icon: Icons.water_drop,
    ),
    FoodTemplate(
      name: 'Teh Kemasan',
      category: 'Minuman',
      defaultExpiryDays: 180,
      defaultUnit: 'botol',
      defaultQuantity:  1,
      storageLocation: 'Kulkas',
      icon: Icons.local_drink,
    ),

    // BUMBU
    FoodTemplate(
      name: 'Bawang Merah',
      category: 'Bumbu',
      defaultExpiryDays: 30,
      defaultUnit: 'gram',
      defaultQuantity: 250,
      storageLocation: 'Rak Dapur',
      icon: Icons.spa,
    ),
    FoodTemplate(
      name: 'Bawang Putih',
      category: 'Bumbu',
      defaultExpiryDays: 30,
      defaultUnit: 'gram',
      defaultQuantity: 250,
      storageLocation: 'Rak Dapur',
      icon: Icons.spa,
    ),
    FoodTemplate(
      name: 'Jahe',
      category: 'Bumbu',
      defaultExpiryDays: 21,
      defaultUnit: 'gram',
      defaultQuantity:  100,
      storageLocation: 'Kulkas',
      icon: Icons.spa,
    ),

    // ROTI & BAKERY
    FoodTemplate(
      name: 'Roti Tawar',
      category: 'Roti',
      defaultExpiryDays: 5,
      defaultUnit: 'bungkus',
      defaultQuantity: 1,
      storageLocation: 'Rak Dapur',
      icon: Icons.bakery_dining,
    ),
    FoodTemplate(
      name: 'Roti Manis',
      category: 'Roti',
      defaultExpiryDays: 3,
      defaultUnit: 'buah',
      defaultQuantity:  4,
      storageLocation: 'Rak Dapur',
      icon: Icons.bakery_dining,
    ),

    // FROZEN FOOD
    FoodTemplate(
      name: 'Nugget',
      category: 'Frozen',
      defaultExpiryDays: 90,
      defaultUnit: 'gram',
      defaultQuantity:  500,
      storageLocation: 'Freezer',
      icon: Icons. ac_unit,
    ),
    FoodTemplate(
      name:  'Sosis Beku',
      category: 'Frozen',
      defaultExpiryDays: 90,
      defaultUnit: 'gram',
      defaultQuantity: 500,
      storageLocation: 'Freezer',
      icon:  Icons.ac_unit,
    ),
    FoodTemplate(
      name: 'Es Krim',
      category: 'Frozen',
      defaultExpiryDays: 180,
      defaultUnit: 'liter',
      defaultQuantity:  1,
      storageLocation: 'Freezer',
      icon: Icons.icecream,
    ),
  ];

  // Mendapatkan semua kategori unik
  static List<String> get categories {
    return templates.map((t) => t.category).toSet().toList().. sort();
  }

  // Filter template berdasarkan kategori
  static List<FoodTemplate> getByCategory(String category) {
    return templates.where((t) => t.category == category).toList();
  }

  // Search template berdasarkan nama
  static List<FoodTemplate> search(String query) {
    if (query.isEmpty) return templates;
    return templates
        .where((t) => t.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}