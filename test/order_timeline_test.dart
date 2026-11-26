import 'package:batik_app/widgets/orders/order_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shipped order shows only shipping as the current stage', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OrderTimeline(status: 'shipped', paymentSucceeded: true),
        ),
      ),
    );
    expect(find.bySemanticsLabel('Dikirim, Saat ini'), findsOneWidget);
    expect(find.bySemanticsLabel('Selesai, Belum tercapai'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets(
    'cancelled order with late payment has no active delivery milestone',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OrderTimeline(status: 'cancelled', paymentSucceeded: true),
          ),
        ),
      );
      expect(
        find.text('Pesanan dibatalkan. Pembayaran tercatat berhasil.'),
        findsOneWidget,
      );
      expect(find.text('Dikirim'), findsNothing);
      expect(find.text('Saat ini'), findsNothing);
    },
  );

  testWidgets('unrecognized status stays neutral', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: OrderTimeline(status: 'Unknown')),
      ),
    );
    expect(find.text('Perjalanan pesanan belum tersedia.'), findsOneWidget);
    expect(find.text('Menunggu bayar'), findsNothing);
  });
}
