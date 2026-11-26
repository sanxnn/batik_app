import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../controllers/bundle_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/product_controller.dart';
import '../models/bundle_model.dart';
import '../models/category_model.dart';
import '../models/order_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../widgets/common/app_network_image.dart';
import '../widgets/common/app_count_badge.dart';
import '../widgets/common/app_state_view.dart';
import '../widgets/home/category_item.dart';
import '../widgets/home/home_search_bar.dart';
import '../widgets/home/section_header.dart';
import '../widgets/product/product_grid.dart';
import 'bundle_detail_view.dart';
import 'cart_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _searchController = TextEditingController();
  final _bannerController = PageController();
  Timer? _debounce;
  Timer? _bannerTimer;
  int _bannerIndex = 0;
  bool _initialRequestPending = true;
  bool _showBundles = false;

  static const _banners = [
    'assets/images/rubung_banner_batik_1.jpeg',
    'assets/images/rubung_banner_batik_2.jpeg',
    'assets/images/rubung_banner_batik_3.jpeg',
    'assets/images/rubung_banner_batik_4.jpeg',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<ProductController>().fetchInitialData();
      if (mounted) setState(() => _initialRequestPending = false);
    });
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_bannerController.hasClients) return;
      _bannerController.animateToPage(
        (_bannerIndex + 1) % _banners.length,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _bannerTimer?.cancel();
    _searchController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  void _search(String value) {
    _debounce?.cancel();
    if (_showBundles) {
      setState(() => _showBundles = false);
      context.read<ProductController>().searchProducts(value);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) context.read<ProductController>().searchProducts(value);
    });
  }

  void _submitSearch(String value) {
    _debounce?.cancel();
    if (_showBundles) setState(() => _showBundles = false);
    context.read<ProductController>().searchProducts(value);
  }

  void _resetFilters() {
    _debounce?.cancel();
    _searchController.clear();
    if (_showBundles) setState(() => _showBundles = false);
    context.read<ProductController>().resetFilters();
  }

  bool _isBundleCategory(CategoryModel category) =>
      category.slug.toLowerCase() == 'bundling' ||
      category.slug.toLowerCase() == 'bundle';

  void _selectCategory(CategoryModel? category) {
    _debounce?.cancel();
    _searchController.clear();
    final products = context.read<ProductController>();
    if (category != null && _isBundleCategory(category)) {
      if (_showBundles) {
        _resetFilters();
      } else {
        products.resetFilters(refresh: false);
        setState(() => _showBundles = true);
        context.read<BundleController>().load(refresh: true);
      }
      return;
    }
    final wasShowingBundles = _showBundles;
    if (wasShowingBundles) setState(() => _showBundles = false);
    if (category == null ||
        (!wasShowingBundles && products.selectedCategoryId == category.id)) {
      products.resetFilters();
    } else {
      products.selectCategory(category.id);
    }
  }

  Future<void> _refresh() async {
    if (_showBundles) {
      await context.read<BundleController>().load(refresh: true);
    } else {
      await context.read<ProductController>().fetchInitialData();
    }
  }

  void _openCategories() {
    final controller = context.read<ProductController>();
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(AppSpacing.page),
          children: [
            Text(
              'Pilih kategori',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              title: const Text('Semua produk'),
              selected: !_showBundles && controller.selectedCategoryId == null,
              onTap: () {
                _selectCategory(null);
                Navigator.pop(sheetContext);
              },
            ),
            for (final category in controller.categories)
              ListTile(
                title: Text(category.name),
                selected: _isBundleCategory(category)
                    ? _showBundles
                    : !_showBundles &&
                          controller.selectedCategoryId == category.id,
                onTap: () {
                  _selectCategory(category);
                  Navigator.pop(sheetContext);
                },
              ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(String name) {
    final label = name.toLowerCase();
    if (label.contains('kain') || label.contains('bahan')) {
      return Icons.layers_outlined;
    }
    if (label.contains('batik')) return Icons.checkroom_outlined;
    if (label.contains('bundl')) return Icons.inventory_2_outlined;
    return Icons.category_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductController>();
    final bundles = context.watch<BundleController>();
    final user = context.watch<AuthController>().user;
    final cartCount = context.watch<CartController>().totalItems;
    final greetingName = user?.name.split(' ').first ?? 'Sahabat Batik';
    final initialLoading =
        _initialRequestPending ||
        (products.isLoading && products.products.isEmpty);
    final filtered =
        _showBundles ||
        products.searchQuery.isNotEmpty ||
        products.selectedCategoryId != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.contentMaxWidth,
            ),
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        AppSpacing.md,
                        AppSpacing.page,
                        AppSpacing.xl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selamat datang,',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                    Text(
                                      greetingName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                  ],
                                ),
                              ),
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  IconButton.filledTonal(
                                    tooltip: 'Buka keranjang',
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const CartView(),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.shopping_bag_outlined,
                                    ),
                                  ),
                                  if (cartCount > 0)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: AppCountBadge(count: cartCount),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          HomeSearchBar(
                            controller: _searchController,
                            onChanged: _search,
                            onSubmitted: _submitSearch,
                            onFilter: _openCategories,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AspectRatio(
                            aspectRatio: AppSpacing.bannerAspectRatio,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              child: PageView.builder(
                                controller: _bannerController,
                                itemCount: _banners.length,
                                onPageChanged: (index) => _bannerIndex = index,
                                itemBuilder: (context, index) => Image.asset(
                                  _banners[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const ColoredBox(
                                    color: AppColors.surfaceMuted,
                                    child: Center(
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          SectionHeader(
                            title: 'Kategori',
                            action: filtered
                                ? TextButton(
                                    onPressed: _resetFilters,
                                    child: const Text('Reset'),
                                  )
                                : null,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          SizedBox(
                            height: AppSpacing.categoryHeight,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: products.categories.length + 1,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: AppSpacing.xs),
                              itemBuilder: (context, index) {
                                final category = index == 0
                                    ? null
                                    : products.categories[index - 1];
                                return CategoryItem(
                                  label: category?.name ?? 'Semua',
                                  icon: category == null
                                      ? Icons.grid_view_outlined
                                      : _categoryIcon(category.name),
                                  selected: category == null
                                      ? !_showBundles &&
                                            products.selectedCategoryId == null
                                      : _isBundleCategory(category)
                                      ? _showBundles
                                      : !_showBundles &&
                                            category.id ==
                                                products.selectedCategoryId,
                                  onTap: () => _selectCategory(category),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          SectionHeader(
                            title: _showBundles
                                ? 'Paket bundling'
                                : filtered
                                ? 'Hasil pencarian'
                                : 'Produk unggulan',
                            subtitle: _showBundles
                                ? 'Jelajahi paket Batik Rubung Kuning'
                                : filtered
                                ? 'Produk sesuai pilihanmu'
                                : 'Jelajahi koleksi Batik Rubung Kuning',
                            action: filtered
                                ? TextButton(
                                    onPressed: _resetFilters,
                                    child: const Text('Hapus filter'),
                                  )
                                : null,
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ),
                    ),
                  ),
                  if (_showBundles &&
                      bundles.isLoading &&
                      bundles.bundles.isEmpty)
                    const SliverToBoxAdapter(
                      child: SizedBox(
                        height: AppSpacing.stateHeight,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  else if (_showBundles &&
                      bundles.errorMessage != null &&
                      bundles.bundles.isEmpty)
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: AppSpacing.stateHeight,
                        child: AppStateView(
                          icon: Icons.cloud_off_outlined,
                          title: 'Paket belum termuat',
                          message: bundles.errorMessage!,
                          actionLabel: 'Coba lagi',
                          onAction: () => bundles.load(refresh: true),
                        ),
                      ),
                    )
                  else if (_showBundles && bundles.bundles.isEmpty)
                    const SliverToBoxAdapter(
                      child: SizedBox(
                        height: AppSpacing.stateHeight,
                        child: AppStateView(
                          icon: Icons.inventory_2_outlined,
                          title: 'Belum ada paket bundling',
                          message: 'Paket bundling akan tampil di sini.',
                        ),
                      ),
                    )
                  else if (_showBundles) ...[
                    SliverToBoxAdapter(
                      child: _BundleSection(bundles: bundles.bundles),
                    ),
                    if (bundles.canLoadMore || bundles.errorMessage != null)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.page),
                          child: OutlinedButton(
                            onPressed: bundles.isLoading
                                ? null
                                : () => bundles.load(),
                            child: Text(
                              bundles.errorMessage == null
                                  ? 'Muat paket lainnya'
                                  : 'Coba lagi',
                            ),
                          ),
                        ),
                      ),
                  ] else if (initialLoading)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.page,
                      ),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (_, _) => const _ProductSkeleton(),
                          childCount: 4,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: AppSpacing.productMaxWidth,
                              mainAxisExtent: AppSpacing.productHeight,
                              crossAxisSpacing: AppSpacing.sm,
                              mainAxisSpacing: AppSpacing.sm,
                            ),
                      ),
                    )
                  else if (products.errorMessage != null &&
                      products.products.isEmpty)
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: AppSpacing.stateHeight,
                        child: AppStateView(
                          icon: Icons.cloud_off_outlined,
                          title: 'Produk belum termuat',
                          message: products.errorMessage!,
                          actionLabel: 'Coba lagi',
                          onAction: products.fetchInitialData,
                        ),
                      ),
                    )
                  else if (products.products.isEmpty)
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: AppSpacing.stateHeight,
                        child: AppStateView(
                          icon: Icons.search_off_outlined,
                          title: 'Produk tidak ditemukan',
                          message: 'Coba kata kunci atau kategori lain.',
                          actionLabel: 'Lihat semua',
                          onAction: _resetFilters,
                        ),
                      ),
                    )
                  else ...[
                    ProductGrid(products: products.products),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.page),
                        child:
                            products.canLoadMore ||
                                products.errorMessage != null
                            ? OutlinedButton(
                                onPressed: products.loadMore,
                                child: Text(
                                  products.errorMessage == null
                                      ? 'Muat produk lainnya'
                                      : 'Coba lagi',
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ],
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.xl),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BundleSection extends StatelessWidget {
  const _BundleSection({required this.bundles});
  final List<BundleModel> bundles;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.xs,
        AppSpacing.page,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: AppSpacing.bundleHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: bundles.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final bundle = bundles[index];
                final variant = bundle.variants.isEmpty
                    ? null
                    : bundle.variants.first;
                return SizedBox(
                  width: AppSpacing.bundleWidth,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: variant == null
                          ? null
                          : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    BundleDetailView(bundle: bundle),
                              ),
                            ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppNetworkImage(url: bundle.imageUrl),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bundle.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: AppSpacing.xxs),
                                if (variant != null)
                                  Text(
                                    formatRupiah(variant.price),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductSkeleton extends StatelessWidget {
  const _ProductSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const Expanded(child: ColoredBox(color: AppColors.surfaceMuted)),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              children: [
                Container(
                  height: AppSpacing.md,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  height: AppSpacing.md,
                  width: 90,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
