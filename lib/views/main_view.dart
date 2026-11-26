import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home_view.dart';
import 'profile_view.dart';
import 'cart_view.dart';
import 'order_view.dart';
import '../controllers/cart_controller.dart';
import '../widgets/home/app_bottom_nav.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomeView(),
          CartView(onExplore: () => setState(() => _currentIndex = 0)),
          const OrderView(),
          const ProfileView(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: _currentIndex,
        onSelected: (index) => setState(() => _currentIndex = index),
        cartCount: context.watch<CartController>().totalItems,
      ),
    );
  }
}
