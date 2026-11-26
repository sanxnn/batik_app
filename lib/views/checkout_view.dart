import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/address_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/order_controller.dart';
import '../core/utils/api_error.dart';
import '../models/address_model.dart';
import '../models/cart_model.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import '../widgets/auth/auth_button.dart';
import '../widgets/checkout/checkout_steps.dart';
import '../widgets/common/form_error.dart';
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
  int _step = 1;
  int? _addressId;
  VoucherPreview? _preview;
  CartModel? _previewCart;
  String? _voucherError;
  String? _orderError;
  bool _loadingAddresses = true;
  bool _checkingVoucher = false;
  bool _submitting = false;

  bool get _busy => _checkingVoucher || _submitting;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadAddresses();
    });
  }

  @override
  void dispose() {
    _voucher.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _loadAddresses() async {
    final controller = context.read<AddressController>();
    setState(() => _loadingAddresses = true);
    await controller.fetchAddresses();
    if (!mounted) return;
    setState(() {
      _loadingAddresses = false;
      if (_selectedAddress(controller) == null) {
        _addressId = controller.primaryAddress?.id;
      }
    });
  }

  AddressModel? _selectedAddress(AddressController addresses) =>
      addresses.addresses.where((item) => item.id == _addressId).firstOrNull;

  Future<void> _manageAddresses() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const AddressView()),
    );
    if (mounted) await _loadAddresses();
  }

  Future<bool> _checkVoucher() async {
    if (_checkingVoucher || _voucher.text.trim().isEmpty) return false;
    final cart = context.read<CartController>();
    if (cart.isEmpty || cart.isLoading || cart.isUpdating) return false;
    final cartSnapshot = cart.cart;
    final service = context.read<OrderController>().service;
    setState(() {
      _checkingVoucher = true;
      _preview = null;
      _voucherError = null;
    });
    try {
      final result = await service.validateVoucher(_voucher.text.trim());
      if (!mounted) return false;
      if (!identical(cartSnapshot, cart.cart)) {
        setState(
          () => _voucherError = 'Keranjang berubah. Periksa voucher lagi.',
        );
        return false;
      }
      setState(() {
        _preview = result;
        _previewCart = cartSnapshot;
      });
      return true;
    } catch (error) {
      if (mounted) setState(() => _voucherError = apiErrorMessage(error));
      return false;
    } finally {
      if (mounted) setState(() => _checkingVoucher = false);
    }
  }

  Future<void> _checkout() async {
    final cart = context.read<CartController>();
    final addresses = context.read<AddressController>();
    final orders = context.read<OrderController>();
    final address = _selectedAddress(addresses);
    if (_busy ||
        orders.isSaving ||
        cart.isEmpty ||
        cart.isLoading ||
        cart.isUpdating ||
        address == null ||
        addresses.errorMessage != null) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
      _orderError = null;
    });
    try {
      if (_voucher.text.trim().isNotEmpty &&
          (_preview == null || !identical(_previewCart, cart.cart))) {
        if (!await _checkVoucher() || !mounted) return;
      }
      final result = await orders.checkout(
        addressId: address.id,
        voucherCode: _preview?.code,
        notes: _notes.text.trim(),
      );
      if (!mounted) return;
      if (result == null) {
        setState(
          () => _orderError = orders.errorMessage ?? 'Pesanan gagal dibuat.',
        );
        return;
      }
      cart.clearLocal();
      cart.fetchCart();
      Navigator.pushReplacement<void, void>(
        context,
        MaterialPageRoute(
          builder: (_) => OrderDetailView(
            orderId: result.order.id,
            initialOrder: result.order,
            checkoutPaymentStep: true,
            initialSnapToken: result.snapToken,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _back() {
    if (_busy) return;
    if (_step == 2) {
      FocusScope.of(context).unfocus();
      setState(() => _step = 1);
    } else {
      Navigator.maybePop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final addresses = context.watch<AddressController>();
    final cart = context.watch<CartController>();
    final orders = context.watch<OrderController>();
    final selected = _selectedAddress(addresses);
    final busy = _busy || orders.isSaving;
    final canContinue =
        !busy &&
        !_loadingAddresses &&
        addresses.errorMessage == null &&
        selected != null &&
        !cart.isEmpty &&
        !cart.isLoading &&
        !cart.isUpdating;
    return PopScope(
      canPop: _step == 1 && !busy,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _step == 2) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Kembali',
            onPressed: busy ? null : _back,
            icon: const BackButtonIcon(),
          ),
          title: const Text('Checkout'),
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            key: PageStorageKey('checkout-step-$_step'),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              CheckoutSteps(step: _step),
              const SizedBox(height: 24),
              if (cart.isEmpty && !cart.isLoading)
                const FormError(
                  'Keranjang kosong. Kembali ke katalog untuk memilih barang.',
                ),
              if (_step == 1)
                ..._addressStep(addresses, busy)
              else if (selected != null)
                ..._reviewStep(selected, cart),
              const SizedBox(height: 20),
              if (_orderError case final error?) ...[
                FormError(error),
                const Text(
                  'Jika koneksi terputus, periksa tab Pesanan sebelum mencoba lagi.',
                ),
                const SizedBox(height: 12),
              ],
              AuthButton(
                text: _step == 1 ? 'Tinjau pesanan' : 'Buat pesanan',
                icon: _step == 1
                    ? Icons.arrow_forward_rounded
                    : Icons.receipt_long_outlined,
                isLoading: _submitting || orders.isSaving,
                onPressed: !canContinue
                    ? null
                    : _step == 1
                    ? () => setState(() => _step = 2)
                    : _checkout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _addressStep(AddressController addresses, bool busy) => [
    Text('Alamat pengiriman', style: Theme.of(context).textTheme.titleLarge),
    const SizedBox(height: 10),
    if (_loadingAddresses)
      const LinearProgressIndicator(semanticsLabel: 'Memuat alamat'),
    if (addresses.errorMessage case final message?)
      FormError(message)
    else if (!_loadingAddresses && addresses.addresses.isEmpty)
      const Text('Tambahkan alamat untuk melanjutkan.'),
    for (final address in addresses.addresses)
      Card.outlined(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          selected: address.id == _addressId,
          leading: Icon(
            address.id == _addressId
                ? Icons.radio_button_checked
                : Icons.radio_button_off,
          ),
          title: Text(address.label),
          subtitle: Text('${address.recipientName}\n${_addressText(address)}'),
          onTap: busy || _loadingAddresses
              ? null
              : () => setState(() => _addressId = address.id),
        ),
      ),
    Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: busy || _loadingAddresses ? null : _manageAddresses,
        icon: const Icon(Icons.edit_location_alt_outlined),
        label: const Text('Kelola alamat'),
      ),
    ),
  ];

  List<Widget> _reviewStep(AddressModel selected, CartController cart) {
    final theme = Theme.of(context);
    final preview = identical(_previewCart, cart.cart) ? _preview : null;
    return [
      Text('Tinjau pesanan', style: theme.textTheme.titleLarge),
      const SizedBox(height: 8),
      Card.outlined(
        margin: EdgeInsets.zero,
        child: ListTile(
          leading: const Icon(Icons.location_on_outlined),
          title: Text('${selected.label} · ${selected.recipientName}'),
          subtitle: Text(_addressText(selected)),
        ),
      ),
      const SizedBox(height: 16),
      for (final item in cart.items)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 4,
            children: [
              Text('${item.variant.product.name} × ${item.quantity}'),
              Text(formatRupiah(item.subtotal)),
            ],
          ),
        ),
      const Divider(height: 24),
      _amount('Subtotal barang', cart.totalPrice),
      if (preview != null) ...[
        _amount('Potongan voucher', -preview.discount),
        _amount('Subtotal setelah voucher', preview.subtotalAfterVoucher),
      ],
      const SizedBox(height: 6),
      Text(
        'Promo otomatis, ongkir, dan total akhir terlihat setelah pesanan dibuat.',
        style: theme.textTheme.bodySmall,
      ),
      const SizedBox(height: 20),
      TextField(
        controller: _voucher,
        enabled: !_busy,
        onChanged: (_) => setState(() {
          _preview = null;
          _voucherError = null;
        }),
        decoration: const InputDecoration(labelText: 'Kode voucher (opsional)'),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: _busy || cart.isEmpty || _voucher.text.trim().isEmpty
              ? null
              : _checkVoucher,
          child: Text(_checkingVoucher ? 'Memeriksa voucher…' : 'Cek voucher'),
        ),
      ),
      if (_voucherError case final message?) FormError(message),
      TextField(
        controller: _notes,
        enabled: !_busy,
        maxLines: 2,
        decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
      ),
    ];
  }

  String _addressText(AddressModel address) => [
    address.detail,
    address.village,
    address.district,
    address.city,
    address.province,
    address.postalCode,
  ].whereType<String>().where((part) => part.isNotEmpty).join(', ');

  Widget _amount(String label, num value) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Wrap(
      spacing: 12,
      runSpacing: 4,
      alignment: WrapAlignment.spaceBetween,
      children: [Text(label), Text(formatRupiah(value))],
    ),
  );
}
