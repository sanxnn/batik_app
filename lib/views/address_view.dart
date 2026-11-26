import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/address_controller.dart';
import '../models/address_model.dart';
import '../widgets/common/content_state.dart';
import 'form_address_view.dart';

enum _AddressAction { edit, primary, remove }

class AddressView extends StatefulWidget {
  const AddressView({super.key});

  @override
  State<AddressView> createState() => _AddressViewState();
}

class _AddressViewState extends State<AddressView> {
  bool _mutating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AddressController>().fetchAddresses();
    });
  }

  void _openForm([AddressModel? address]) => Navigator.push(
    context,
    MaterialPageRoute<bool>(builder: (_) => AddressFormView(address: address)),
  );

  Future<void> _action(_AddressAction action, AddressModel address) async {
    if (_mutating) return;
    if (action == _AddressAction.edit) {
      _openForm(address);
      return;
    }
    final removing = action == _AddressAction.remove;
    if (removing) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
          title: const Text('Hapus alamat?'),
          content: Text('Alamat “${address.label}” akan dihapus dari daftar.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialog, true),
              child: Text(
                'Hapus',
                style: TextStyle(color: Theme.of(dialog).colorScheme.error),
              ),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted || _mutating) return;
    }
    setState(() => _mutating = true);
    final controller = context.read<AddressController>();
    final success = removing
        ? await controller.deleteAddress(address.id)
        : await controller.setPrimary(address.id);
    if (!mounted) return;
    setState(() => _mutating = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (removing ? 'Alamat dihapus.' : 'Alamat utama diperbarui.')
              : controller.errorMessage ?? 'Alamat gagal diperbarui.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddressController>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Alamat saya')),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: FilledButton.icon(
          onPressed: _mutating ? null : _openForm,
          icon: const Icon(Icons.add_location_alt_outlined),
          label: const Text('Tambah alamat'),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchAddresses,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          children: [
            if (controller.isLoading || _mutating)
              const LinearProgressIndicator(semanticsLabel: 'Memuat alamat'),
            if (controller.errorMessage case final error?)
              ContentState(
                icon: Icons.sync_problem_rounded,
                message: error,
                onRetry: controller.fetchAddresses,
              )
            else if (controller.addresses.isEmpty && !controller.isLoading)
              const ContentState(
                icon: Icons.location_on_outlined,
                message: 'Belum ada alamat pengiriman.',
              ),
            for (final address in controller.addresses)
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: scheme.surface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: scheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              address.label,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          PopupMenuButton<_AddressAction>(
                            tooltip: 'Opsi alamat ${address.label}',
                            enabled: !_mutating,
                            onSelected: (action) => _action(action, address),
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: _AddressAction.edit,
                                child: Text('Edit alamat'),
                              ),
                              if (!address.isPrimary)
                                const PopupMenuItem(
                                  value: _AddressAction.primary,
                                  child: Text('Jadikan alamat utama'),
                                ),
                              const PopupMenuItem(
                                value: _AddressAction.remove,
                                child: Text('Hapus alamat'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (address.isPrimary)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            'Alamat utama',
                            style: TextStyle(
                              color: scheme.onSecondaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      Text(
                        address.recipientName,
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(address.phone),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          [
                                address.detail,
                                address.village,
                                address.district,
                                address.city,
                                address.province,
                                address.postalCode,
                              ]
                              .whereType<String>()
                              .where((part) => part.isNotEmpty)
                              .join(', '),
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
