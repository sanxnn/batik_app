import 'package:batik_app/controllers/auth_controller.dart';
import 'package:batik_app/controllers/bundle_controller.dart';
import 'package:batik_app/controllers/cart_controller.dart';
import 'package:batik_app/controllers/order_controller.dart';
import 'package:batik_app/controllers/product_controller.dart';
import 'package:batik_app/core/network/api_client.dart';
import 'package:batik_app/theme/app_theme.dart';
import 'package:batik_app/views/home_view.dart';
import 'package:batik_app/views/main_view.dart';
import 'package:batik_app/widgets/catalog/catalog_add_button.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  setUpAll(
    () => dotenv.testLoad(fileInput: 'API_BASE_URL=https://example.test/api'),
  );

  test('brand text and enabled input outlines have sufficient contrast', () {
    double contrast(Color fore, Color back) {
      final a = fore.computeLuminance();
      final b = back.computeLuminance();
      return a > b ? (a + 0.05) / (b + 0.05) : (b + 0.05) / (a + 0.05);
    }

    final theme = AppTheme.lightTheme;
    final scheme = theme.colorScheme;
    expect(
      contrast(scheme.onPrimary, scheme.primary),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      contrast(scheme.onSecondaryContainer, scheme.secondaryContainer),
      greaterThanOrEqualTo(4.5),
    );
    final input = theme.inputDecorationTheme;
    expect(
      contrast(input.enabledBorder!.borderSide.color, input.fillColor!),
      greaterThanOrEqualTo(3),
    );
  });

  testWidgets(
    'tabs preserve catalog scroll and exclude hidden focus at 200% text',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 620));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final products = List.generate(
        16,
        (id) => {
          'id': id + 1,
          'name': 'Produk batik ${id + 1}',
          'slug': 'produk-$id',
          'variants': [
            {
              'id': id + 1,
              'name': 'Kain 2 m',
              'sku': 'BT-$id',
              'price': 250000,
              'stock': 4,
            },
          ],
        },
      );
      final intercept = InterceptorsWrapper(
        onRequest: (request, handler) {
          final data = switch (request.path) {
            '/categories' || '/bundles' || '/orders' => {'data': <Object>[]},
            '/products' => {
              'data': {'data': products, 'current_page': 1, 'last_page': 1},
            },
            '/cart' => {
              'data': {'id': 1, 'items': <Object>[]},
            },
            _ => throw StateError('Unexpected request ${request.path}'),
          };
          handler.resolve(Response(requestOptions: request, data: data));
        },
      );
      final dio = ApiClient.instance.dio;
      dio.interceptors.add(intercept);
      addTearDown(() => dio.interceptors.remove(intercept));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthController()),
            ChangeNotifierProvider(create: (_) => ProductController()),
            ChangeNotifierProvider(create: (_) => BundleController()),
            ChangeNotifierProvider(create: (_) => CartController()),
            ChangeNotifierProvider(create: (_) => OrderController()),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(2),
                disableAnimations: true,
              ),
              child: child!,
            ),
            home: const MainView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final bar = find.byType(NavigationBar);
      expect(
        tester.widget<NavigationBar>(bar).animationDuration,
        Duration.zero,
      );
      final search = tester.widget<EditableText>(find.byType(EditableText));
      search.focusNode.requestFocus();
      await tester.pumpAndSettle();

      Finder tab(String label) =>
          find.descendant(of: bar, matching: find.text(label));
      await tester.tap(tab('Keranjang'));
      await tester.pumpAndSettle();
      expect(find.text('Keranjang masih kosong.'), findsOneWidget);
      expect(search.focusNode.hasFocus, isFalse);
      expect(search.focusNode.canRequestFocus, isFalse);

      await tester.tap(find.text('Lihat katalog'));
      await tester.pumpAndSettle();
      final scrollView = find.descendant(
        of: find.byType(HomeView),
        matching: find.byType(CustomScrollView),
      );
      await tester.drag(scrollView, const Offset(0, -410));
      await tester.pumpAndSettle();
      final scrollable = find
          .descendant(of: scrollView, matching: find.byType(Scrollable))
          .first;
      final scroll = tester.state<ScrollableState>(scrollable).position;
      final offset = scroll.pixels;
      expect(offset, greaterThan(0));
      await tester.tap(tab('Pesanan'));
      await tester.pumpAndSettle();
      await tester.tap(tab('Beranda'));
      await tester.pumpAndSettle();
      expect(scroll.pixels, offset);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('cart success check is immediate with Reduce Motion', (
    tester,
  ) async {
    final intercept = InterceptorsWrapper(
      onRequest: (request, handler) {
        expect(request.path, '/cart/items');
        expect(request.data, {'product_variant_id': 7, 'quantity': 1});
        handler.resolve(
          Response(
            requestOptions: request,
            data: {
              'data': {'id': 1, 'items': <Object>[]},
            },
          ),
        );
      },
    );
    final dio = ApiClient.instance.dio;
    dio.interceptors.add(intercept);
    addTearDown(() => dio.interceptors.remove(intercept));

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => CartController(),
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: const Scaffold(body: CatalogAddButton(variantId: 7)),
        ),
      ),
    );
    await tester.tap(find.text('Tambah ke keranjang'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(find.text('Ditambahkan ke keranjang'), findsOneWidget);
    expect(find.byType(AnimatedSwitcher), findsNothing);
    await tester.pump(const Duration(milliseconds: 1100));
    expect(find.byIcon(Icons.add_shopping_cart_rounded), findsOneWidget);
  });
}
