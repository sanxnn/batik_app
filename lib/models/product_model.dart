// models/product_model.dart
import 'package:batik_app/models/category_model.dart';

class ProductModel {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? image;
  final CategoryModel? category;
  final SubcategoryModel? subcategory;
  final List<VariantModel> variants;

  ProductModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.image,
    this.category,
    this.subcategory,
    required this.variants,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      image: json['image'],
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'])
          : null,
      subcategory: json['subcategory'] != null
          ? SubcategoryModel.fromJson(json['subcategory'])
          : null,
      variants:
          (json['variants'] as List<dynamic>?)
              ?.map((e) => VariantModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  VariantModel get cheapestVariant {
    if (variants.isEmpty) {
      return VariantModel(
        id: 0,
        name: 'Default',
        sku: 'N/A',
        price: 0,
        stock: 0,
      );
    }
    return variants.reduce((a, b) => a.price < b.price ? a : b);
  }

  String get formattedPrice {
    final price = cheapestVariant.price;
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String get imageUrl {
    if (image == null || image!.isEmpty) {
      return 'https://via.placeholder.com/400x400?text=No+Image';
    }
    // Gabungkan dengan base URL backend Anda (sesuaikan jika perlu)
    return 'http://welcomed-redbird-vital.ngrok-free.app/storage/$image';
  }
}

class VariantModel {
  final int id;
  final String name;
  final String sku;
  final double price;
  final int stock;

  VariantModel({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.stock,
  });

  factory VariantModel.fromJson(Map<String, dynamic> json) {
    return VariantModel(
      id: json['id'],
      name: json['name'],
      sku: json['sku'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      stock: json['stock'] ?? 0,
    );
  }
}
