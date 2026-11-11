import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/address_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/order_controller.dart';
import '../models/order_model.dart';
import '../theme/app_theme.dart';
import 'address_view.dart';
import 'order_detail_view.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final _voucher = TextEditingController();
  final _notes = TextEditingController();
  int? _addressId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<AddressController>().fetchAddresses();
      if (!mounted) return;
      final primary = context.read<AddressController>().primaryAddress;
      setState(() => _addressId = primary?.id);
    });
  }

  @override
  void dispose() {
    _voucher.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _checkout() async {
    if (_addressId == null) {
      _message('Pilih alamat pengiriman terlebih dahulu.');
      return;
    }
    final cart = context.read<CartController>();
    if (cart.isEmpty) {
      _message('Keranjang kosong.');
      return;
    }
    final controller = context.read<OrderController>();
    final result = await controller.checkout(
      addressId: _addressId!,
      voucherCode: _voucher.text.trim(),
      notes: _notes.text.trim(),
    );
    if (!mounted) return;
    if (result == null) {
      _message(controller.errorMessage ?? 'Checkout gagal. Silakan coba lagi.');
      return;
    }
    // Order sudah tersimpan di server; pengguna tetap dapat membayar dari riwayat.
    await cart.fetchCart();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailView(
          orderId: result.order.id,
          initialOrder: result.order,
        ),
      ),
    );
  }

  void _message(String message) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: AppTheme.error),
  );

  @override
  Widget build(BuildContext context) {
    final addresses = context.watch<AddressController>();
    final cart = context.watch<CartController>();
    final orders = context.watch<OrderController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Alamat pengiriman',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (addresses.isLoading) const LinearProgressIndicator(),
          if (addresses.errorMessage != null)
            Text(
              addresses.errorMessage!,
              style: const TextStyle(color: AppTheme.error),
            ),
          if (!addresses.isLoading && addresses.addresses.isEmpty)
            const Text('Belum ada alamat. Tambahkan alamat sebelum checkout.'),
          for (final address in addresses.addresses)
            ListTile(
              selected: _addressId == address.id,
              leading: Icon(
                _addressId == address.id
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
              ),
              title: Text('${address.label} • ${address.recipientName}'),
              subtitle: Text(
                '${address.detail}, ${address.city}, ${address.province} ${address.postalCode}',
              ),
              onTap: orders.isSaving
                  ? null
                  : () => setState(() => _addressId = address.id),
            ),
          TextButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddressView()),
              );
              if (!mounted) return;
              await addresses.fetchAddresses();
              if (!mounted) return;
              if (!addresses.addresses.any(
                (address) => address.id == _addressId,
              )) {
                setState(() => _addressId = addresses.primaryAddress?.id);
              }
            },
            icon: const Icon(Icons.edit_location_alt_outlined),
            label: const Text('Kelola alamat'),
          ),
          const Divider(height: 32),
          Text('Ringkasan', style: Theme.of(context).textTheme.titleMedium),
          for (final item in cart.items)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(item.variant.product.name),
              subtitle: Text('${item.variant.name} • ${item.quantity} item'),
              trailing: Text(formatRupiah(item.subtotal)),
            ),
          TextField(
            controller: _voucher,
            decoration: const InputDecoration(
              labelText: 'Kode voucher (opsional)',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notes,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
          ),
          const SizedBox(height: 20),
          Text(
            'Subtotal: ${formatRupiah(cart.totalPrice)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            'Diskon dan ongkir final akan dihitung oleh server saat checkout.',
          ),
          if (orders.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                orders.errorMessage!,
                style: const TextStyle(color: AppTheme.error),
              ),
            ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed:
                orders.isSaving ||
                    addresses.isLoading ||
                    addresses.errorMessage != null ||
                    _addressId == null ||
                    cart.isEmpty
                ? null
                : _checkout,
            child: Text(
              orders.isSaving
                  ? 'Membuat pesanan...'
                  : 'Buat pesanan dan lanjut bayar',
            ),
          ),
        ],
      ),
    );
  }
}
