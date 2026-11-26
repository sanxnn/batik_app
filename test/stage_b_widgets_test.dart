import 'dart:async';

import 'package:batik_app/controllers/order_controller.dart';
import 'package:batik_app/models/cart_model.dart';
import 'package:batik_app/models/order_model.dart';
import 'package:batik_app/services/order_service.dart';
import 'package:batik_app/theme/app_theme.dart';
import 'package:batik_app/views/order_view.dart';
import 'package:batik_app/widgets/auth/auth_layout.dart';
import 'package:batik_app/widgets/cart/cart_item_card.dart';
import 'package:batik_app/widgets/common/order_card.dart';
import 'package:batik_app/widgets/common/status_chip.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class _OrderService extends OrderService {
  _OrderService(this.page) : super(dio: Dio());

  final Future<OrderPage> page;

  @override
  Future<OrderPage> getOrders({int page = 1}) => this.page;
}

Widget _app(Widget child) => MaterialApp(
  theme: AppTheme.lightTheme,
  builder: (context, content) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: const TextScaler.linear(1.3)),
    child: content!,
  ),
  home: child,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  final order = OrderModel(
    id: 1,
    number: 'BRK-2026-000001',
    status: 'shipped',
    total: 1250000,
    subtotal: 1200000,
    discount: 0,
    shippingCost: 50000,
    createdAt: DateTime(2026, 11, 12),
    items: const [],
  );

  for (final size in [const Size(360, 780), const Size(430, 900)]) {
    testWidgets('komponen Tahap B tetap rapi pada $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final item = CartItemModel(
        id: 1,
        quantity: 2,
        variant: CartVariantModel(
          id: 2,
          name: 'Ukuran panjang dengan nama varian yang panjang',
          sku: 'B-1',
          price: 325000,
          stock: 5,
          product: CartProductModel(
            id: 3,
            name: 'Batik tulis Rubung Kuning dengan nama produk panjang',
            slug: 'batik-tulis',
          ),
        ),
      );
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                CartItemCard(
                  item: item,
                  isUpdating: false,
                  onQuantityChanged: (_) {},
                  onDelete: () {},
                ),
                const SizedBox(height: 12),
                OrderCard(
                  order: order,
                  statusLabel: 'Dikirim',
                  statusTone: AppStatusTone.info,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(CartItemCard), findsOneWidget);
      expect(find.byType(OrderCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('layout autentikasi tetap dapat digulir pada layar kecil', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      _app(
        const AuthLayout(
          title: 'Masuk',
          subtitle: 'Masuk ke akun Batik Rubung Kuning.',
          child: TextField(decoration: InputDecoration(labelText: 'Email')),
        ),
      ),
    );
    expect(find.text('Batik Rubung Kuning'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pesanan menampilkan loading, data, kosong, dan error', (
    tester,
  ) async {
    final waiting = Completer<OrderPage>();
    final controller = OrderController(service: _OrderService(waiting.future));
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: _app(const OrderView()),
      ),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    waiting.complete(OrderPage([order], 1, 1));
    await tester.pump();
    await tester.pump();
    expect(find.text(order.number), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => OrderController(
          service: _OrderService(Future.value(const OrderPage([], 1, 1))),
        ),
        child: _app(const OrderView()),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Belum ada pesanan'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => OrderController(
          service: _OrderService(Future.error(StateError('Koneksi gagal'))),
        ),
        child: _app(const OrderView()),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Pesanan belum termuat'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
