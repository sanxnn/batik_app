import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/address_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/order_controller.dart';
import '../models/order_model.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/common/app_app_bar.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/app_section.dart';
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
    final canCheckout =
        !orders.isSaving &&
        !addresses.isLoading &&
        addresses.errorMessage == null &&
        _addressId != null &&
        !cart.isEmpty;
    return Scaffold(
      appBar: const AppAppBar(title: 'Checkout'),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          const AppSection(title: 'Alamat pengiriman'),
          if (addresses.isLoading) const LinearProgressIndicator(),
          if (addresses.errorMessage != null)
            AppCard(
              child: Text(
                addresses.errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.danger),
              ),
            ),
          if (!addresses.isLoading && addresses.addresses.isEmpty)
            const AppCard(
              child: Text(
                'Belum ada alamat. Tambahkan alamat sebelum checkout.',
              ),
            ),
          for (final address in addresses.addresses) ...[
            AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  _addressId == address.id
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: _addressId == address.id
                      ? AppColors.ink
                      : AppColors.textSecondary,
                ),
                onTap: orders.isSaving
                    ? null
                    : () => setState(() => _addressId = address.id),
                title: Text('${address.label} • ${address.recipientName}'),
                subtitle: Text(
                  '${address.detail}, ${address.city}, ${address.province} ${address.postalCode}',
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
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
          const SizedBox(height: AppSpacing.xl),
          const AppSection(title: 'Ringkasan belanja'),
          AppCard(
            child: Column(
              children: [
                for (final item in cart.items)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.variant.product.name),
                    subtitle: Text(
                      '${item.variant.name} • ${item.quantity} item',
                    ),
                    trailing: Text(formatRupiah(item.subtotal)),
                  ),
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Subtotal',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      formatRupiah(cart.totalPrice),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Diskon dan ongkir final dihitung oleh server saat checkout.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xl),
          const AppSection(title: 'Informasi tambahan'),
          TextField(
            controller: _voucher,
            decoration: const InputDecoration(
              labelText: 'Kode voucher (opsional)',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _notes,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
          ),
          if (orders.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              orders.errorMessage!,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.danger),
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: ElevatedButton(
            onPressed: canCheckout ? _checkout : null,
            child: Text(
              orders.isSaving
                  ? 'Membuat pesanan...'
                  : 'Buat pesanan dan lanjut bayar',
            ),
          ),
        ),
      ),
    );
  }
}
