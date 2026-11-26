import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/bundle_controller.dart';
import '../controllers/product_controller.dart';
import '../models/category_model.dart';
import '../models/order_model.dart';
import '../widgets/catalog/catalog_image.dart';
import '../widgets/common/content_state.dart';
import '../widgets/home/home_search_bar.dart';
import '../widgets/product/product_card.dart';
import 'bundle_detail_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _search = TextEditingController();
  final _banner = PageController();
  Timer? _debounce;
  int _bannerIndex = 0;
  bool _initialLoading = true;

  static const _banners = [
    'assets/images/rubung_banner_batik_1.jpeg',
    'assets/images/rubung_banner_batik_2.jpeg',
    'assets/images/rubung_banner_batik_3.jpeg',
    'assets/images/rubung_banner_batik_4.jpeg',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refresh();
    });
  }

  Future<void> _refresh() async {
    _debounce?.cancel();
    final products = context.read<ProductController>();
    final bundles = context.read<BundleController>();
    try {
      await Future.wait([
        products.fetchInitialData(),
        bundles.load(refresh: true),
      ]);
    } finally {
      if (mounted && _initialLoading) setState(() => _initialLoading = false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _banner.dispose();
    super.dispose();
  }

  void _submit(String value) {
    _debounce?.cancel();
    final query = value.trim();
    final products = context.read<ProductController>();
    final category = products.categories
        .where((item) => item.id == products.selectedCategoryId)
        .firstOrNull;
    if (category == null || category.slug == 'bundling') {
      context.read<BundleController>().search(query);
    }
    products.searchProducts(query);
  }

  void _select(CategoryModel? category) {
    _debounce?.cancel();
    _search.clear();
    context.read<BundleController>().search('');
    final controller = context.read<ProductController>();
    if (category == null) {
      controller.resetFilters();
    } else {
      controller.selectCategory(category.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductController>();
    final bundles = context.watch<BundleController>();
    final category = products.categories
        .where((item) => item.id == products.selectedCategoryId)
        .firstOrNull;
    final showBundles =
        category?.slug == 'bundling' ||
        (category == null &&
            (products.searchQuery.isEmpty ||
                bundles.bundles.isNotEmpty ||
                bundles.isLoading ||
                bundles.errorMessage != null));
    final bundleOnly = category?.slug == 'bundling';
    final theme = Theme.of(context);
    final loadingProducts = products.isLoading || _initialLoading;
    final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
    return Scaffold(
      appBar: AppBar(title: const Text('Batik Rubung Kuning')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          key: const PageStorageKey('catalog-scroll'),
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeSearchBar(
                      controller: _search,
                      onChanged: (query) {
                        _debounce?.cancel();
                        _debounce = Timer(
                          const Duration(milliseconds: 350),
                          () => _submit(query),
                        );
                      },
                      onSubmitted: _submit,
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _filter(
                            'Semua',
                            category == null,
                            () => _select(null),
                          ),
                          for (final item in products.categories)
                            _filter(
                              item.name,
                              category?.id == item.id,
                              () => _select(item),
                            ),
                        ],
                      ),
                    ),
                    if (category == null && products.searchQuery.isEmpty) ...[
                      const SizedBox(height: 16),
                      _bannerSection(context),
                    ],
                  ],
                ),
              ),
            ),
            if (!bundleOnly) ...[
              SliverToBoxAdapter(
                child: _heading(
                  context,
                  products.searchQuery.isNotEmpty
                      ? 'Hasil pencarian produk'
                      : (category?.name ?? 'Katalog'),
                ),
              ),
              if (products.products.isEmpty && loadingProducts)
                SliverToBoxAdapter(
                  child: Semantics(liveRegion: true, label: 'Memuat produk'),
                ),
              if (products.products.isEmpty && !loadingProducts)
                SliverToBoxAdapter(
                  child: ContentState(
                    icon: products.errorMessage == null
                        ? Icons.search_off_rounded
                        : Icons.sync_problem_rounded,
                    message:
                        products.errorMessage ??
                        'Produk reguler tidak ditemukan.',
                    onRetry: products.errorMessage == null ? null : _refresh,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: textScale > 1.45 ? 440 : 235,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent:
                          272 + 100 * (textScale - 1).clamp(0, 2).toDouble(),
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, index) => products.products.isEmpty
                          ? const _CatalogSkeleton()
                          : ProductCard(product: products.products[index]),
                      childCount: products.products.isEmpty
                          ? 4
                          : products.products.length,
                      semanticIndexCallback: (_, index) =>
                          products.products.isEmpty ? null : index,
                    ),
                  ),
                ),
              if (products.products.isNotEmpty &&
                  (products.isLoading || products.canLoadMore))
                SliverToBoxAdapter(
                  child: Center(
                    child: products.isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(
                              semanticsLabel: 'Memuat produk lainnya',
                            ),
                          )
                        : TextButton(
                            onPressed: products.canLoadMore
                                ? products.loadMore
                                : null,
                            child: Text(
                              products.errorMessage != null
                                  ? 'Coba muat lagi'
                                  : 'Muat produk lainnya',
                            ),
                          ),
                  ),
                ),
            ],
            if (showBundles)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Paket bundling', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 12),
                      if (bundles.bundles.isEmpty)
                        if (bundles.isLoading)
                          const ContentLoading(label: 'Memuat paket')
                        else
                          ContentState(
                            icon: bundles.errorMessage == null
                                ? Icons.inventory_2_outlined
                                : Icons.sync_problem_rounded,
                            message: bundles.errorMessage ?? 'Belum ada paket.',
                            onRetry: bundles.errorMessage == null
                                ? null
                                : () => bundles.load(refresh: true),
                          ),
                      for (final bundle in bundles.bundles)
                        Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(10),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox.square(
                                dimension: 52,
                                child: CatalogImage(
                                  url: bundle.imageUrl,
                                  label: bundle.name,
                                ),
                              ),
                            ),
                            title: Text(bundle.name),
                            subtitle: bundle.variants.isEmpty
                                ? null
                                : Text(
                                    'Mulai ${formatRupiah(bundle.variants.map((v) => v.price).reduce((a, b) => a < b ? a : b))}',
                                  ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    BundleDetailView(bundleId: bundle.id),
                              ),
                            ),
                          ),
                        ),
                      if (bundles.bundles.isNotEmpty && bundles.isLoading)
                        const ContentLoading(label: 'Memuat paket lainnya'),
                      if (bundles.bundles.isNotEmpty && bundles.canLoadMore)
                        TextButton(
                          onPressed: () => bundles.load(),
                          child: Text(
                            bundles.errorMessage != null
                                ? 'Coba muat lagi'
                                : 'Muat paket lainnya',
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }

  Widget _heading(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
    child: Text(title, style: Theme.of(context).textTheme.titleLarge),
  );

  Widget _filter(String label, bool selected, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    ),
  );

  Widget _bannerSection(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final single = reduceMotion || constraints.maxWidth < 320;
        Widget photo(int index) => Image.asset(
          _banners[index],
          fit: BoxFit.contain,
          semanticLabel: 'Koleksi Batik Rubung Kuning, gambar ${index + 1}',
        );
        return Column(
          children: [
            AspectRatio(
              aspectRatio: 2.28,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: single
                    ? photo(0)
                    : PageView.builder(
                        controller: _banner,
                        itemCount: _banners.length,
                        onPageChanged: (index) =>
                            setState(() => _bannerIndex = index),
                        itemBuilder: (_, index) => photo(index),
                      ),
              ),
            ),
            if (!single)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    tooltip: 'Banner sebelumnya',
                    onPressed: _bannerIndex == 0 ? null : () => _moveBanner(-1),
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  Text('${_bannerIndex + 1} / ${_banners.length}'),
                  IconButton(
                    tooltip: 'Banner berikutnya',
                    onPressed: _bannerIndex == _banners.length - 1
                        ? null
                        : () => _moveBanner(1),
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  void _moveBanner(int offset) => _banner.animateToPage(
    (_bannerIndex + offset).clamp(0, _banners.length - 1),
    duration: const Duration(milliseconds: 200),
    curve: Curves.easeOut,
  );
}

class _CatalogSkeleton extends StatelessWidget {
  const _CatalogSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            margin: const EdgeInsets.all(12),
            height: 16,
            width: 84,
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ),
    );
  }
}
