import 'package:batik_app/models/cart_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cart computes item count and subtotal from API variant', () {
    final cart = CartModel.fromJson({
      'id': 2,
      'items': [
        {
          'id': 9,
          'quantity': 2,
          'variant': {
            'id': 41,
            'name': '2 Meter',
            'sku': 'BT-2M',
            'price': 250000,
            'stock': 5,
            'product': {'id': 12, 'name': 'Batik Tulis', 'slug': 'batik-tulis'},
          },
        },
      ],
    });
    expect(cart.totalItems, 2);
    expect(cart.totalPrice, 500000);
    expect(cart.items.single.id, 9);
  });
}
