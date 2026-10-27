import 'dart:async';

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
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductController>().fetchInitialData();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<ProductController>().searchProducts(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Consumer2<AuthController, ProductController>(
        builder: (context, authCtrl, prodCtrl, _) {
          final user = authCtrl.user;
          final isInitialLoading =
              prodCtrl.isLoading && prodCtrl.products.isEmpty;

          if (isInitialLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryDark),
            );
          }

          return CustomScrollView(
            slivers: [
              // 1. Sliver AppBar (Header Premium)
              SliverAppBar(
                expandedHeight: 130,
                floating: true,
                pinned: true,
                backgroundColor: AppTheme.background,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 50, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
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
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            color: AppTheme.textPrimary,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Konten Utama (Search & Kategori)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kategori',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 42,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: prodCtrl.categories.length + 1,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
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
                              isSelected:
                                  prodCtrl.selectedCategoryId == category.id,
                              onTap: () => prodCtrl.selectCategory(category.id),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),
                      HomeSearchBar(
                        controller: _searchCtrl,
                        onChanged: _onSearchChanged,
                        onSubmitted: _onSearchChanged,
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            prodCtrl.searchQuery.isNotEmpty
                                ? 'Hasil Pencarian'
                                : (prodCtrl.selectedCategoryId != null
                                      ? 'Produk Kategori'
                                      : 'Rekomendasi Untukmu'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          if (prodCtrl.selectedCategoryId != null ||
                              prodCtrl.searchQuery.isNotEmpty)
                            TextButton.icon(
                              onPressed: () {
                                _searchCtrl.clear();
                                prodCtrl.resetFilters();
                              },
                              icon: const Icon(Icons.close, size: 16),
                              label: const Text(
                                'Reset',
                                style: TextStyle(
                                  color: AppTheme.error,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // 3. Loading State
              if (prodCtrl.isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ),
                )
              // 4. Error State
              else if (prodCtrl.errorMessage != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 40,
                      horizontal: 24,
                    ),
                    child: Center(
                      child: Text(
                        prodCtrl.errorMessage!,
                        style: const TextStyle(
                          color: AppTheme.error,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              // 5. Empty State
              else if (prodCtrl.products.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: const Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: Color(0xFFD9A400),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Produk tidak ditemukan',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            prodCtrl.searchQuery.isNotEmpty
                                ? 'Coba kata kunci lain atau periksa ejaan.'
                                : 'Belum ada produk di kategori ini.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              _searchCtrl.clear();
                              prodCtrl.resetFilters();
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Lihat Semua Produk'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: AppTheme.textPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              // 6. Product Grid
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 110),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.62,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return ProductCard(product: prodCtrl.products[index]);
                    }, childCount: prodCtrl.products.length),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
