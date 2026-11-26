import 'package:batik_app/controllers/address_controller.dart';
import 'package:batik_app/views/form_address_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/address_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/common/app_app_bar.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/status_chip.dart';
import '../widgets/common/app_state_view.dart';

class AddressView extends StatefulWidget {
  const AddressView({super.key});

  @override
  State<AddressView> createState() => _AddressViewState();
}

class _AddressViewState extends State<AddressView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AddressController>().fetchAddresses();
      }
    });
  }

  void _openForm({AddressModel? address}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddressFormView(address: address)),
    );

    if (result == true && mounted) {
      context.read<AddressController>().fetchAddresses();
    }
  }

  void _confirmDelete(AddressModel address) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Alamat'),
        content: Text(
          'Apakah Anda yakin ingin menghapus alamat ${address.label}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              final success = await context
                  .read<AddressController>()
                  .deleteAddress(address.id);

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Alamat berhasil dihapus.'
                        : 'Gagal menghapus alamat.',
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: 'Alamat Saya'),
      body: Consumer<AddressController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.errorMessage != null && controller.addresses.isEmpty) {
            return AppStateView(
              icon: Icons.cloud_off_outlined,
              title: 'Alamat belum termuat',
              message: controller.errorMessage!,
              actionLabel: 'Coba lagi',
              onAction: controller.fetchAddresses,
            );
          }
          if (controller.addresses.isEmpty) {
            return AppStateView(
              icon: Icons.location_off_outlined,
              title: 'Belum ada alamat',
              message: 'Tambahkan alamat untuk mempermudah pengiriman pesanan.',
              actionLabel: 'Tambah alamat',
              onAction: () => _openForm(),
            );
          }
          return RefreshIndicator(
            onRefresh: controller.fetchAddresses,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.page),
              children: [
                Text(
                  'Alamat pengiriman',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                for (final address in controller.addresses) ...[
                  _buildAddressCard(address, controller),
                  const SizedBox(height: AppSpacing.sm),
                ],
                OutlinedButton.icon(
                  onPressed: () => _openForm(),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Tambah alamat baru'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddressCard(AddressModel address, AddressController controller) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  address.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (address.isPrimary)
                const StatusChip(label: 'Utama', tone: AppStatusTone.success),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            address.recipientName,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(address.phone, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${address.detail}, '
            '${address.district == null ? '' : '${address.district}, '}'
            '${address.city}, ${address.province}, '
            '${address.postalCode}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            children: [
              TextButton.icon(
                onPressed: () => _openForm(address: address),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
              ),
              TextButton.icon(
                onPressed: () => _confirmDelete(address),
                icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                label: const Text('Hapus'),
              ),
              if (!address.isPrimary)
                TextButton(
                  onPressed: () async {
                    final success = await controller.setPrimary(address.id);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Alamat utama berhasil diubah.'
                              : 'Gagal mengubah alamat utama.',
                        ),
                      ),
                    );
                  },
                  child: const Text('Jadikan utama'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
