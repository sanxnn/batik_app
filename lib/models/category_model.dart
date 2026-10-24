// models/category_model.dart
class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final bool hasSubcategories;
  final int productsCount;
  final List<SubcategoryModel> subcategories;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.hasSubcategories,
    required this.productsCount,
    required this.subcategories,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      hasSubcategories: json['has_subcategories'] ?? false,
      productsCount: json['products_count'] ?? 0,
      subcategories:
          (json['subcategories'] as List<dynamic>?)
              ?.map((e) => SubcategoryModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class SubcategoryModel {
  final int id;
  final String name;
  final String slug;

  SubcategoryModel({required this.id, required this.name, required this.slug});

  factory SubcategoryModel.fromJson(Map<String, dynamic> json) {
    return SubcategoryModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
    );
  }
}
