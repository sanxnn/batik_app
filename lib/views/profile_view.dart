import 'package:batik_app/views/address_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../controllers/address_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/order_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/common/app_app_bar.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/app_menu_tile.dart';
import 'edit_profile_view.dart';
import 'custom_order_view.dart';
import 'order_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar akun?'),
        content: const Text('Kamu perlu masuk kembali untuk mengakses akun.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<AuthController>().logout();
      if (!mounted) return;
      context.read<CartController>().clearLocal();
      context.read<AddressController>().clearLocal();
      context.read<OrderController>().clear();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: 'Akun Saya'),
      body: Consumer<AuthController>(
        builder: (context, authCtrl, _) {
          final user = authCtrl.user;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final initial = user.name.isNotEmpty
              ? user.name[0].toUpperCase()
              : '?';
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.page),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSpacing.contentMaxWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppCard(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: AppSpacing.xxl,
                              backgroundColor: AppColors.yellowSoft,
                              child: Text(
                                initial,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge,
                                  ),
                                  const SizedBox(height: AppSpacing.xxs),
                                  Text(
                                    user.email,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Akun',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppCard(
                        child: Column(
                          children: [
                            AppMenuTile(
                              icon: Icons.person_outline_rounded,
                              title: 'Edit Profil',
                              subtitle: 'Ubah informasi akun',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EditProfileView(),
                                ),
                              ),
                            ),
                            const Divider(),
                            AppMenuTile(
                              icon: Icons.location_on_outlined,
                              title: 'Alamat Saya',
                              subtitle: 'Kelola alamat pengiriman',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddressView(),
                                ),
                              ),
                            ),
                            const Divider(),
                            AppMenuTile(
                              icon: Icons.shopping_bag_outlined,
                              title: 'Pesanan Saya',
                              subtitle: 'Status dan riwayat pesanan',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const OrderView(),
                                ),
                              ),
                            ),
                            const Divider(),
                            AppMenuTile(
                              icon: Icons.design_services_outlined,
                              title: 'Custom Order',
                              subtitle: 'Lihat dan buat pesanan khusus',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CustomOrderView(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppCard(
                        child: AppMenuTile(
                          icon: Icons.logout_rounded,
                          title: 'Keluar Akun',
                          subtitle: 'Akhiri sesi akun ini',
                          danger: true,
                          onTap: _handleLogout,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
