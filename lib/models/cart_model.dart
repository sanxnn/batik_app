// lib/models/cart_model.dart
import '../core/network/image_url.dart';

class CartModel {
  final int id;
  final List<CartItemModel> items;

  CartModel({required this.id, required this.items});

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: _toInt(json['id']),
      items: (json['items'] as List? ?? [])
          .map(
            (item) => CartItemModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
    );
  }

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalPrice {
    return items.fold(0, (sum, item) => sum + item.subtotal);
  }
}

// ==========================================
// CART ITEM
// ==========================================

class CartItemModel {
  final int id;
  final int quantity;
  final CartVariantModel variant;

  CartItemModel({
    required this.id,
    required this.quantity,
    required this.variant,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final variantJson =
        json['product_variant'] ?? json['productVariant'] ?? json['variant'];

    if (variantJson == null) {
      throw FormatException(
        'Relasi product_variant tidak ditemukan pada cart item.',
      );
    }

    return CartItemModel(
      id: _toInt(json['id']),
      quantity: _toInt(json['quantity']),
      variant: CartVariantModel.fromJson(
        Map<String, dynamic>.from(variantJson),
      ),
    );
  }

  double get subtotal => variant.price * quantity;

  bool get isPreOrder => variant.stock <= 0;
}

// ==========================================
// CART VARIANT
// ==========================================

class CartVariantModel {
  final int id;
  final String name;
  final String sku;
  final double price;
  final int stock;
  final CartProductModel product;

  CartVariantModel({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.stock,
    required this.product,
  });

  factory CartVariantModel.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'];

    if (productJson == null) {
      throw FormatException(
        'Relasi product tidak ditemukan pada product variant.',
      );
    }

    return CartVariantModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      price: _toDouble(json['price']),
      stock: _toInt(json['stock']),
      product: CartProductModel.fromJson(
        Map<String, dynamic>.from(productJson),
      ),
    );
  }
}

// ==========================================
// CART PRODUCT
// Disesuaikan dengan ProductModel milikmu
// ==========================================

class CartProductModel {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? image;

  CartProductModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.image,
  });

  factory CartProductModel.fromJson(Map<String, dynamic> json) {
    return CartProductModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? 'Produk tidak ditemukan',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      image: json['image']?.toString(),
    );
  }

  // Mengikuti pola imageUrl pada ProductModel
  String get imageUrl {
    return productImageUrl(image);
  }
}

// ==========================================
// CONVERSION HELPERS
// ==========================================

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();

  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();

  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}
