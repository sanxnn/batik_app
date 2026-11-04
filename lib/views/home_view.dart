import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_view.dart';
import '../controllers/product_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/home/home_search_bar.dart';
import '../widgets/category/category_chip.dart';
import '../widgets/product/product_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _searchCtrl = TextEditingController();

  final PageController _bannerPageController = PageController();

  Timer? _debounce;
  Timer? _bannerTimer;

  int _currentBannerIndex = 0;

  // DATA BANNER SLIDESHOW
  static const List<String> _banners = [
    'assets/images/rubung_banner_batik_1.jpeg',
    'assets/images/rubung_banner_batik_2.jpeg',
    'assets/images/rubung_banner_batik_3.jpeg',
    'assets/images/rubung_banner_batik_4.jpeg',
  ];

  static const Color _textDark = Color(0xFF252525);
  static const Color _textGrey = Color(0xFF888888);
  static const Color _divider = Color(0xFFEAEAEA);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<ProductController>().fetchInitialData();
    });

    // SLIDESHOW OTOMATIS SETIAP 4 DETIK
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || !_bannerPageController.hasClients) return;

      final nextPage = (_currentBannerIndex + 1) % _banners.length;

      _bannerPageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _bannerTimer?.cancel();

    _searchCtrl.dispose();
    _bannerPageController.dispose();

    super.dispose();
  }

  // ==========================================
  // BANNER SLIDESHOW
  // ==========================================

  Widget _buildBannerSlider() {
    return Column(
      children: [
        SizedBox(
          height: 145,
          width: double.infinity,
          child: PageView.builder(
            controller: _bannerPageController,
            itemCount: _banners.length,

            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },

            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),

                  child: Image.asset(
                    _banners[index],
                    width: double.infinity,
                    height: 145,
                    fit: BoxFit.fill,

                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFFFE7A3),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: Color(0xFF8B5A00),
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // INDIKATOR SLIDESHOW
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) {
            final isActive = _currentBannerIndex == index;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,

              margin: const EdgeInsets.symmetric(horizontal: 4),

              width: isActive ? 22 : 7,
              height: 7,

              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.primaryDark
                    : const Color(0xFFD8D8D8),

                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ==========================================
  // SEARCH DENGAN DEBOUNCE
  // ==========================================

  void _onSearchChanged(String query) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      context.read<ProductController>().searchProducts(query);
    });
  }

  // SEARCH SAAT TOMBOL KEYBOARD DITEKAN
  void _onSearchSubmitted(String query) {
    _debounce?.cancel();

    context.read<ProductController>().searchProducts(query);
  }

  // RESET SEARCH DAN KATEGORI
  void _resetFilters() {
    _debounce?.cancel();
    _searchCtrl.clear();

    context.read<ProductController>().resetFilters();
  }

  // NAVIGASI KERANJANG
  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

      body: Consumer<ProductController>(
        builder: (context, prodCtrl, _) {
          final isInitialLoading =
              prodCtrl.isLoading && prodCtrl.products.isEmpty;

          return CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

            slivers: [
              // ==========================================
              // 1. APP BAR
              // ==========================================

              SliverAppBar(
                floating: true,
                toolbarHeight: 64,
                elevation: 0,
                scrolledUnderElevation: 0,
                backgroundColor: AppTheme.background,
                surfaceTintColor: Colors.transparent,
                automaticallyImplyLeading: false,
                titleSpacing: 20,

                title: const Text(
                  'Rubung Batik Kuning',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                    letterSpacing: -0.5,
                  ),
                ),

                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),

                    child: IconButton(
                      onPressed: _openCart,
                      tooltip: 'Keranjang',

                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _textDark,
                        side: const BorderSide(color: _divider),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),

                        fixedSize: const Size(44, 44),
                      ),

                      icon: const Icon(Icons.shopping_bag_outlined, size: 21),
                    ),
                  ),
                ],
              ),

              // ==========================================
              // 2. HEADER, SEARCH, DAN BANNER
              // ==========================================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // SEARCH BAR
                      HomeSearchBar(
                        controller: _searchCtrl,
                        onChanged: _onSearchChanged,
                        onSubmitted: _onSearchSubmitted,
                      ),

                      const SizedBox(height: 22),

                      // ==================================
                      // BANNER SLIDESHOW
                      // ==================================
                      _buildBannerSlider(),

                      const SizedBox(height: 27),

                      // ==================================
                      // 3. KATEGORI
                      // ==================================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          const Text(
                            'Kategori',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                            ),
                          ),

                          if (prodCtrl.selectedCategoryId != null)
                            GestureDetector(
                              onTap: _resetFilters,

                              child: const Text(
                                'Reset',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryDark,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 13),

                      SizedBox(
                        height: 40,

                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,

                          itemCount: prodCtrl.categories.length + 1,

                          separatorBuilder: (_, __) => const SizedBox(width: 9),

                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return CategoryChip(
                                label: 'Semua',

                                isSelected: prodCtrl.selectedCategoryId == null,

                                onTap: () {
                                  prodCtrl.selectCategory(null);
                                },
                              );
                            }

                            final category = prodCtrl.categories[index - 1];

                            return CategoryChip(
                              label: category.name,

                              isSelected:
                                  prodCtrl.selectedCategoryId == category.id,

                              onTap: () {
                                prodCtrl.selectCategory(category.id);
                              },
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 27),

                      // ==================================
                      // 4. HEADER PRODUK
                      // ==================================
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,

                        children: [
                          Expanded(
                            child: Text(
                              prodCtrl.searchQuery.isNotEmpty
                                  ? 'Hasil Pencarian'
                                  : prodCtrl.selectedCategoryId != null
                                  ? 'Produk Kategori'
                                  : 'Rekomendasi Untukmu',

                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: _textDark,
                              ),
                            ),
                          ),

                          if (prodCtrl.searchQuery.isNotEmpty ||
                              prodCtrl.selectedCategoryId != null)
                            GestureDetector(
                              onTap: _resetFilters,

                              child: const Text(
                                'Hapus filter',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _textGrey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        '${prodCtrl.products.length} produk ditemukan',

                        style: const TextStyle(fontSize: 12, color: _textGrey),
                      ),

                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),

              // ==========================================
              // 5. PROGRESS INDIKATOR
              // ==========================================
              if (prodCtrl.isLoading && !isInitialLoading)
                const SliverToBoxAdapter(
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    backgroundColor: Colors.transparent,
                    color: AppTheme.primaryDark,
                  ),
                ),

              // ==========================================
              // 6. INITIAL LOADING
              // ==========================================
              if (isInitialLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,

                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryDark,
                      strokeWidth: 2.5,
                    ),
                  ),
                )
              // ==========================================
              // 7. ERROR STATE
              // ==========================================
              else if (prodCtrl.errorMessage != null &&
                  prodCtrl.products.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,

                  child: _buildMessageState(
                    icon: Icons.cloud_off_outlined,
                    title: 'Gagal Memuat Produk',
                    description: prodCtrl.errorMessage!,
                    buttonText: 'Coba Lagi',

                    onPressed: () {
                      context.read<ProductController>().fetchInitialData();
                    },
                  ),
                )
              // ==========================================
              // 8. EMPTY STATE
              // ==========================================
              else if (prodCtrl.products.isEmpty && !prodCtrl.isLoading)
                SliverFillRemaining(
                  hasScrollBody: false,

                  child: _buildMessageState(
                    icon: Icons.search_off_rounded,
                    title: 'Produk Tidak Ditemukan',

                    description: prodCtrl.searchQuery.isNotEmpty
                        ? 'Coba kata kunci lain atau periksa ejaan pencarianmu.'
                        : 'Belum ada produk pada kategori ini.',

                    buttonText: 'Lihat Semua Produk',

                    onPressed: _resetFilters,
                  ),
                )
              // ==========================================
              // 9. PRODUCT GRID
              // ==========================================
              else if (prodCtrl.products.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),

                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.68,
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

  // ==========================================
  // EMPTY STATE DAN ERROR STATE
  // ==========================================

  Widget _buildMessageState({
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 76,
              height: 76,

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _divider),
              ),

              child: Icon(icon, size: 34, color: _textGrey),
            ),

            const SizedBox(height: 20),

            Text(
              title,
              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              description,
              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: _textGrey,
              ),
            ),

            const SizedBox(height: 22),

            SizedBox(
              height: 44,

              child: ElevatedButton(
                onPressed: onPressed,

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryDark,
                  foregroundColor: Colors.white,
                  elevation: 0,

                  padding: const EdgeInsets.symmetric(horizontal: 22),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
