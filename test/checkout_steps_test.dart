import 'package:batik_app/widgets/cart/cart_quantity_selector.dart';
import 'package:batik_app/widgets/checkout/checkout_steps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('checkout steps stay readable on a narrow screen at 200% text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 480));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: const Scaffold(body: CheckoutSteps(step: 2)),
      ),
    );
    expect(find.text('1 Alamat'), findsOneWidget);
    expect(find.text('2 Tinjau'), findsOneWidget);
    expect(find.text('3 Bayar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('quantity controls stop at the available stock', (tester) async {
    var quantity = 2;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CartQuantitySelector(
            quantity: quantity,
            stock: 2,
            canRequestMoreWithoutStock: false,
            isUpdating: false,
            onChanged: (value) => quantity = value,
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Tambah jumlah'));
    expect(quantity, 2);
    await tester.tap(find.byTooltip('Kurangi jumlah'));
    expect(quantity, 1);
  });
}
