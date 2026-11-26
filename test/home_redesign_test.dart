import 'dart:async';

import 'package:batik_app/controllers/auth_controller.dart';
import 'package:batik_app/controllers/bundle_controller.dart';
import 'package:batik_app/controllers/cart_controller.dart';
import 'package:batik_app/controllers/product_controller.dart';
import 'package:batik_app/core/utils/api_result.dart';
import 'package:batik_app/models/category_model.dart';
import 'package:batik_app/models/bundle_model.dart';
import 'package:batik_app/models/product_model.dart';
import 'package:batik_app/services/bundle_service.dart';
import 'package:batik_app/services/product_service.dart';
import 'package:batik_app/theme/app_theme.dart';
import 'package:batik_app/theme/app_colors.dart';
import 'package:batik_app/views/home_view.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class _Products extends ProductService {
  _Products(this.result, this.categories) : super(dio: Dio());

  final Future<ApiResult<ProductPage>> result;
  final List<CategoryModel> categories;

  @override
  Future<ApiResult<List<CategoryModel>>> getCategories() async =>
      ApiResult.success(categories);

  @override
  Future<ApiResult<ProductPage>> getProducts({
    int? categoryId,
    String? search,
    int page = 1,
  }) => result;
}

class _Bundles extends BundleService {
  _Bundles(this.bundles) : super(dio: Dio());

  final List<BundleModel> bundles;

  @override
  Future<BundlePage> getBundles({String? search, int page = 1}) async =>
      BundlePage(bundles, 1, 1);
}

Widget _home(
  Future<ApiResult<ProductPage>> result, {
  List<CategoryModel> categories = const [],
  List<BundleModel> bundles = const [],
}) => MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (_) => ProductController(service: _Products(result, categories)),
    ),
    ChangeNotifierProvider(
      create: (_) => BundleController(service: _Bundles(bundles)),
    ),
    ChangeNotifierProvider(create: (_) => CartController()),
    ChangeNotifierProvider(create: (_) => AuthController()),
  ],
  child: MaterialApp(
    key: UniqueKey(),
    theme: AppTheme.lightTheme,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1.3)),
      child: child!,
    ),
    home: const HomeView(),
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  dotenv.testLoad(fileInput: 'API_BASE_URL=https://example.test/api');

  for (final size in [const Size(360, 780), const Size(430, 900)]) {
    testWidgets('Home memuat produk tanpa overflow pada $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final product = ProductModel(
        id: 1,
        name: 'Batik tulis motif panjang untuk acara khusus',
        slug: 'batik',
        variants: [
          VariantModel(
            id: 1,
            name: 'Default',
            sku: 'B-1',
            price: 250000,
            stock: 3,
          ),
        ],
      );
      await tester.pumpWidget(
        _home(Future.value(ApiResult.success(ProductPage([product], 1, 1)))),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Produk unggulan'), findsOneWidget);
      expect(find.byType(PageView), findsOneWidget);
      expect(find.text('Jelajahi produk'), findsNothing);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pump();
      expect(find.text(product.name), findsOneWidget);
      final cartButton = tester.widget<IconButton>(
        find.byWidgetPredicate(
          (widget) =>
              widget is IconButton &&
              widget.tooltip == 'Tambah ${product.name} ke keranjang',
        ),
      );
      expect(
        cartButton.style?.backgroundColor?.resolve({}),
        AppColors.brandYellow,
      );
      expect(cartButton.style?.foregroundColor?.resolve({}), AppColors.ink);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Home menampilkan skeleton, empty, dan error', (tester) async {
    final waiting = Completer<ApiResult<ProductPage>>();
    await tester.pumpWidget(_home(waiting.future));
    await tester.pump();
    await tester.pump();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pump();
    expect(find.byType(Card), findsWidgets);
    waiting.complete(ApiResult.success(const ProductPage([], 1, 1)));
    await tester.pump();
    expect(find.text('Produk tidak ditemukan'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pumpWidget(
      _home(Future.value(ApiResult.error('Koneksi terputus'))),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pump();
    expect(find.text('Produk belum termuat'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Bundling hanya tampil di kategori Bundling; pencarian hanya produk',
    (tester) async {
      const bundle = BundleModel(
        id: 2,
        name: 'Paket Melati',
        slug: 'paket-melati',
        variants: [],
      );
      final category = CategoryModel(
        id: 4,
        name: 'Bundling',
        slug: 'bundling',
        hasSubcategories: false,
        productsCount: 0,
        subcategories: [],
      );
      final product = ProductModel(
        id: 1,
        name: 'Batik Mawar',
        slug: 'batik-mawar',
        variants: [],
      );
      await tester.pumpWidget(
        _home(
          Future.value(ApiResult.success(ProductPage([product], 1, 1))),
          categories: [category],
          bundles: [bundle],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Paket Melati'), findsNothing);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pump();
      expect(find.text('Batik Mawar'), findsOneWidget);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, 500));
      await tester.pump();
      await tester.tap(find.text('Bundling'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pump();
      expect(find.text('Paket Melati'), findsOneWidget);
      expect(find.text('Batik Mawar'), findsNothing);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, 500));
      await tester.pump();
      await tester.enterText(find.byType(TextField).first, 'Batik');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pump();
      expect(find.text('Paket Melati'), findsNothing);
      expect(find.text('Batik Mawar'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
