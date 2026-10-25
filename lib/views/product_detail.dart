import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductDetailView extends StatefulWidget {
  final ProductModel product;

  const ProductDetailView({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailView> createState() =>
      _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  // Warna utama aplikasi.
  static const Color gold = Color(0xFFFFB800);
  static const Color goldDark = Color(0xFFE6A000);
  static const Color cream = Color(0xFFF7F5EF);
  static const Color dark = Color(0xFF292929);
  static const Color grey = Color(0xFF858585);

  // Jumlah barang yang akan dipesan.
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final stock = product.cheapestVariant.stock;

    // Produk dengan stok kosong tetap bisa dipesan.
    final isPreOrder = stock <= 0;

    return Scaffold(
      backgroundColor: cream,

      // ==========================================
      // KONTEN DETAIL PRODUK
      // ==========================================
      body: CustomScrollView(
        slivers: [
          // FOTO PRODUK
          SliverToBoxAdapter(
            child: SizedBox(
              height: 370,
              child: Stack(
                children: [
                  // Gambar produk.
                  Positioned.fill(
                    child: Container(
                      color: const Color(0xFFECEBE7),
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (
                          context,
                          child,
                          loadingProgress,
                        ) {
                          if (loadingProgress == null) {
                            return child;
                          }

                          return const Center(
                            child: CircularProgressIndicator(
                              color: goldDark,
                            ),
                          );
                        },
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 65,
                              color: grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Tombol kembali.
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 12,
                    left: 20,
                    child: _circleButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),

                  // Tombol favorit.
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 12,
                    right: 20,
                    child: _circleButton(
                      icon: Icons.favorite_border_rounded,
                      onTap: () {
                        _showMessage(
                          'Fitur favorit belum diaktifkan.',
                        );
                      },
                    ),
                  ),

                  // Label status produk.
                  Positioned(
                    left: 20,
                    bottom: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEDB5),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPreOrder
                                ? Icons.schedule_rounded
                                : Icons.check_circle_outline_rounded,
                            size: 17,
                            color: dark,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isPreOrder
                                ? 'Pre-Order'
                                : 'Siap Dipesan',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: dark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ==========================================
          // INFORMASI PRODUK
          // ==========================================
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(26),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  22,
                  24,
                  22,
                  32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama toko.
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3CE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'BATIK RUMBUNG KUNING',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF926500),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Nama produk.
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: dark,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Harga produk.
                    Text(
                      product.formattedPrice,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: goldDark,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Informasi stok dan Pre-Order.
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: cream,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color(0xFFFFE7AE),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEDB5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isPreOrder
                                  ? Icons.event_available_rounded
                                  : Icons.inventory_2_outlined,
                              color: goldDark,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isPreOrder
                                      ? 'Pesan melalui Pre-Order'
                                      : 'Produk tersedia',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: dark,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  isPreOrder
                                      ? 'Stok kosong, tetapi kamu tetap '
                                          'bisa memesan produk ini.'
                                      : '$stock produk tersedia dan '
                                          'siap dipesan.',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: grey,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Judul pilihan produk.
                    Row(
                      children: [
                        const Icon(
                          Icons.palette_outlined,
                          color: goldDark,
                          size: 21,
                        ),
                        const SizedBox(width: 9),
                        const Expanded(
                          child: Text(
                            'Pilihan Produk',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: dark,
                            ),
                          ),
                        ),
                        Text(
                          '${product.variants.length} varian',
                          style: const TextStyle(
                            fontSize: 11,
                            color: grey,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Kartu informasi varian.
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color(0xFFEAE6DC),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3CE),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.checkroom_outlined,
                              color: goldDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Produk Batik',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: dark,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.verified_outlined,
                            color: goldDark,
                            size: 20,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Judul deskripsi.
                    const Text(
                      'Deskripsi Produk',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: dark,
                      ),
                    ),

                    const SizedBox(height: 9),

                    // Deskripsi produk.
                    const Text(
                      'Temukan keindahan batik dari Batik '
                      'Rumbung Kuning. Produk ini menghadirkan '
                      'pilihan batik dengan motif menarik untuk '
                      'melengkapi koleksi dan kebutuhanmu. '
                      'Produk yang sedang habis tetap dapat '
                      'dipesan melalui sistem Pre-Order.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.8,
                        color: grey,
                      ),
                    ),

                    const SizedBox(height: 26),

                    // Pengatur jumlah pesanan.
                    const Text(
                      'Jumlah Pesanan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: dark,
                      ),
                    ),

                    const SizedBox(height: 13),

                    Row(
                      children: [
                        _quantityButton(
                          icon: Icons.remove_rounded,
                          onTap: quantity > 1
                              ? () {
                                  setState(() {
                                    quantity--;
                                  });
                                }
                              : null,
                        ),

                        SizedBox(
                          width: 55,
                          child: Center(
                            child: Text(
                              '$quantity',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: dark,
                              ),
                            ),
                          ),
                        ),

                        // Jumlah tetap bisa ditambah
                        // meskipun stok produk kosong.
                        _quantityButton(
                          icon: Icons.add_rounded,
                          onTap: () {
                            setState(() {
                              quantity++;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // Informasi tambahan.
                    if (isPreOrder)
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: goldDark,
                            size: 17,
                          ),
                          SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              'Produk akan diproses sesuai '
                              'ketentuan Pre-Order toko.',
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.5,
                                color: grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // ==========================================
      // TOMBOL PEMBELIAN BAGIAN BAWAH
      // ==========================================
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            18,
            12,
            18,
            12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
          ),
          child: Row(
            children: [
              // Tombol tambah ke keranjang.
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      _showMessage(
                        isPreOrder
                            ? '$quantity produk Pre-Order dipilih. '
                                'Hubungkan tombol ini ke keranjang.'
                            : '$quantity produk dipilih. '
                                'Hubungkan tombol ini ke keranjang.',
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: dark,
                      side: const BorderSide(
                        color: Color(0xFFD9D9D9),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Tambah ke Keranjang',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Tombol beli sekarang.
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      _showMessage(
                        isPreOrder
                            ? '$quantity produk Pre-Order dipilih. '
                                'Hubungkan tombol ini ke checkout.'
                            : '$quantity produk dipilih. '
                                'Hubungkan tombol ini ke checkout.',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: goldDark,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Beli Sekarang',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tombol bulat di bagian atas gambar.
  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.95),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 43,
          height: 43,
          child: Icon(
            icon,
            size: 20,
            color: dark,
          ),
        ),
      ),
    );
  }

  // Tombol tambah dan kurang jumlah barang.
  Widget _quantityButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: onTap == null
          ? const Color(0xFFECE9E1)
          : const Color(0xFFFFEDB5),
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(
            icon,
            size: 19,
            color: dark,
          ),
        ),
      ),
    );
  }

  // Menampilkan notifikasi kepada pengguna.
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}