import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../common/app_count_badge.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.cartCount,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final int cartCount;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          label: 'Beranda',
        ),
        NavigationDestination(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_bag_outlined),
              if (cartCount > 0)
                Positioned(
                  top: -AppSpacing.xs,
                  right: -AppSpacing.sm,
                  child: AppCountBadge(count: cartCount),
                ),
            ],
          ),
          label: 'Keranjang',
        ),
        const NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          label: 'Pesanan',
        ),
        const NavigationDestination(
          icon: Icon(Icons.person_outline),
          label: 'Profil',
        ),
      ],
    );
  }
}
