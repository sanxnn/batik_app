import 'package:batik_app/controllers/address_controller.dart';
import 'package:batik_app/views/form_address_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/address_model.dart';
import '../theme/app_theme.dart';

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
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Alamat Saya',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),

      body: Consumer<AddressController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null && controller.addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(controller.errorMessage!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: controller.fetchAddresses,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (controller.addresses.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_off_outlined,
                      size: 65,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum Ada Alamat',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tambahkan alamat untuk mempermudah pengiriman pesanan.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => _openForm(),
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Alamat'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.fetchAddresses,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Daftar Alamat Pengiriman',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Kelola alamat untuk kebutuhan pengiriman pesanan Anda.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),

                ...controller.addresses.map(
                  (address) => _buildAddressCard(address, controller),
                ),

                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: () => _openForm(),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Alamat Baru'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    foregroundColor: AppTheme.primaryDark,
                    side: const BorderSide(color: AppTheme.primaryDark),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddressCard(AddressModel address, AddressController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: address.isPrimary ? AppTheme.primaryDark : AppTheme.border,
          width: address.isPrimary ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: AppTheme.primaryDark,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (address.isPrimary)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Utama',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            address.recipientName,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),

          const SizedBox(height: 4),

          Text(address.phone, style: const TextStyle(color: Colors.grey)),

          const SizedBox(height: 10),

          Text(
            '${address.detail}, '
            '${address.district == null ? '' : '${address.district}, '}'
            '${address.city}, ${address.province}, '
            '${address.postalCode}',
            style: const TextStyle(height: 1.5, color: AppTheme.textSecondary),
          ),

          const Divider(height: 25),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton.icon(
                onPressed: () => _openForm(address: address),
                icon: const Icon(Icons.edit_outlined, size: 17),
                label: const Text('Edit'),
              ),

              TextButton.icon(
                onPressed: () => _confirmDelete(address),
                icon: const Icon(
                  Icons.delete_outline,
                  size: 17,
                  color: Colors.red,
                ),
                label: const Text('Hapus', style: TextStyle(color: Colors.red)),
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
                  child: const Text('Jadikan Utama'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
