import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/product_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/home/home_search_bar.dart';
import '../widgets/home/category_chip.dart';
import '../widgets/home/product_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch data saat halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductController>().fetchInitialData();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Consumer2<AuthController, ProductController>(
        builder: (context, authCtrl, prodCtrl, _) {
          final user = authCtrl.user;

          if (prodCtrl.isLoading && prodCtrl.products.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryDark));
          }

          return CustomScrollView(
            slivers: [
              // 1. Sliver AppBar (Header yang menempel saat discroll)
              SliverAppBar(
                expandedHeight: 140,
                floating: true,
                pinned: true,
                backgroundColor: AppTheme.background,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 50, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Halo, ${user?.name.split(' ').first ?? 'User'}! 👋',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Temukan Batik Terbaik',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            // Icon Notifikasi / Cart
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: const Icon(Icons.shopping_bag_outlined, color: AppTheme.textPrimary, size: 22),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Konten Utama
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar
                      HomeSearchBar(
                        controller: _searchCtrl,
                        onSearch: () {
                          // Logic search nanti
                        },
                      ),
                      const SizedBox(height: 24),

                      // Kategori (Horizontal Scroll)
                      const Text(
                        'Kategori',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 42,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: prodCtrl.categories.length + 1, // +1 untuk "Semua"
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return CategoryChip(
                                label: 'Semua',
                                isSelected: prodCtrl.selectedCategoryId == null,
                                onTap: () => prodCtrl.selectCategory(null),
                              );
                            }
                            final category = prodCtrl.categories[index - 1];
                            return CategoryChip(
                              label: category.name,
                              isSelected: prodCtrl.selectedCategoryId == category.id,
                              onTap: () => prodCtrl.selectCategory(category.id),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Grid Produk
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Rekomendasi Untukmu Jier',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Lihat Semua', style: TextStyle(color: AppTheme.primaryDark, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // 3. Daftar Produk (Grid)
                prodCtrl.products.isEmpty
                    ? const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: 55,
                                color: Color(0xFFD9A400),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Belum ada produk tersedia',
                                style: TextStyle(
                                  color: Color(0xFF8A8172),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.59,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return ProductCard(
                                product: prodCtrl.products[index],
                              );
                            },
                            childCount: prodCtrl.products.length,
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