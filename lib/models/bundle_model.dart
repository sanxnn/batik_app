import '../core/network/image_url.dart';
import 'product_model.dart';

class BundleModel {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? image;
  final List<BundleVariantModel> variants;

  const BundleModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.image,
    required this.variants,
  });

  factory BundleModel.fromJson(Map<String, dynamic> json) => BundleModel(
    id: (json['id'] as num).toInt(),
    name: json['name']?.toString() ?? 'Paket',
    slug: json['slug']?.toString() ?? '',
    description: json['description']?.toString(),
    image: json['image']?.toString(),
    variants: (json['variants'] as List? ?? const [])
        .map(
          (item) => BundleVariantModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList(),
  );

  String get imageUrl => productImageUrl(image);
}

class BundleVariantModel extends VariantModel {
  final List<BundleComponentModel> components;

  BundleVariantModel({
    required super.id,
    required super.name,
    required super.sku,
    required super.price,
    required super.stock,
    required this.components,
  });

  factory BundleVariantModel.fromJson(Map<String, dynamic> json) =>
      BundleVariantModel(
        id: (json['id'] as num).toInt(),
        name: json['name']?.toString() ?? 'Paket',
        sku: json['sku']?.toString() ?? '',
        price: double.tryParse(json['price'].toString()) ?? 0,
        stock: (json['stock'] as num?)?.toInt() ?? 0,
        components: (json['components'] as List? ?? const [])
            .map(
              (item) => BundleComponentModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList(),
      );
}

class BundleComponentModel {
  final int variantId;
  final String name;
  final String sku;
  final int quantity;
  final int stock;
  final String productName;

  const BundleComponentModel({
    required this.variantId,
    required this.name,
    required this.sku,
    required this.quantity,
    required this.stock,
    required this.productName,
  });

  factory BundleComponentModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'] is Map ? json['product'] as Map : const {};
    return BundleComponentModel(
      variantId: (json['variant_id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      productName: product['name']?.toString() ?? 'Produk',
    );
  }
}
