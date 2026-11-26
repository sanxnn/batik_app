import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/address_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/order_controller.dart';
import 'address_view.dart';
import 'custom_order_view.dart';
import 'edit_profile_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key, required this.onOrders});

  final VoidCallback onOrders;

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text(
          'Kamu perlu masuk kembali untuk membuka pesanan dan alamat.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<AuthController>().logout();
    if (!context.mounted) return;
    context.read<CartController>().clearLocal();
    context.read<AddressController>().clearLocal();
    context.read<OrderController>().clear();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Card(
            color: scheme.secondaryContainer,
            elevation: 0,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: scheme.surface,
                    foregroundColor: scheme.onSecondaryContainer,
                    child: const Icon(Icons.person_rounded),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Akun pelanggan',
                          style: theme.textTheme.titleLarge,
                        ),
                        if (user != null)
                          Text(
                            user.email,
                            style: TextStyle(
                              color: scheme.onSecondaryContainer,
                            ),
                          ),
                        if (user?.isEmailVerified == true) ...[
                          const SizedBox(height: 6),
                          const Text('Email terverifikasi'),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _link(
            context,
            Icons.edit_outlined,
            'Edit profil',
            const EditProfileView(),
            enabled: user != null,
          ),
          _link(
            context,
            Icons.location_on_outlined,
            'Alamat saya',
            const AddressView(),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('Pesanan saya'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: onOrders,
          ),
          _link(
            context,
            Icons.design_services_outlined,
            'Custom order',
            const CustomOrderView(),
          ),
          const Divider(height: 24),
          ListTile(
            leading: Icon(Icons.logout_rounded, color: scheme.error),
            title: Text('Keluar', style: TextStyle(color: scheme.error)),
            onTap: auth.isLoading ? null : () => _logout(context),
          ),
        ],
      ),
    );
  }

  Widget _link(
    BuildContext context,
    IconData icon,
    String title,
    Widget page, {
    bool enabled = true,
  }) => ListTile(
    leading: Icon(icon),
    title: Text(title),
    trailing: const Icon(Icons.chevron_right_rounded),
    onTap: enabled
        ? () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => page),
          )
        : null,
  );
}
