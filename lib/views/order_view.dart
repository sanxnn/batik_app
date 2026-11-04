import 'package:flutter/material.dart';

// ---------- order_model.dart ----------
enum OrderStatus { diproses, dikirim, selesai, dibatalkan }

class OrderModel {
  final String id;
  final String date;
  final int itemCount;
  final OrderStatus status;
  final String image;

  const OrderModel({
    required this.id,
    required this.date,
    required this.itemCount,
    required this.status,
    required this.image,
  });
}

// ---------- order_header.dart ----------
class OrderHeader extends StatelessWidget {
  const OrderHeader({super.key});

  static const _brown = Color(0xFF3B2A1A);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/images/logo.png', // ganti sesuai logo Anda
          width: 40,
          height: 40,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.local_florist,
            size: 36,
            color: Color(0xFFF29A0C),
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Batik Rubung Kuning',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _brown)),
              Text('Lestari dalam Gaya',
                  style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Colors.black54)),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search, color: _brown),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none, color: _brown),
            ),
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                width: 16,
                height: 16,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
                child: const Text('2',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.person_outline, color: _brown),
        ),
      ],
    );
  }
}

// ---------- order_banner.dart ----------
/// Banner "Pesanan Saya" (teks & ilustrasi sudah ada di dalam gambar).
class OrderBanner extends StatelessWidget {
  /// Isi null untuk tinggi otomatis mengikuti rasio gambar.
  /// Isi angka (mis. 150) untuk tinggi tetap.
  final double? height;
  const OrderBanner({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Image.asset(
        'assets/images/banner.png',
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
      )
    );
  }
}

// ---------- order_filter_tabs.dart ----------
class OrderFilterTabs extends StatelessWidget {
  final List<OrderTabItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const OrderFilterTabs({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  static const _orange = Color(0xFFF29A0C);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F4F8),
        borderRadius: BorderRadius.circular(30),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(items.length, (i) {
            final item = items[i];
            final selected = i == selectedIndex;
            return GestureDetector(
              onTap: () => onSelected(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? _orange : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                              color: _orange.withOpacity(.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3))
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(item.icon,
                        size: 18,
                        color: selected ? Colors.white : Colors.black87),
                    const SizedBox(width: 6),
                    Text(item.label,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : Colors.black87)),
                    const SizedBox(width: 6),
                    Container(
                      constraints:
                          const BoxConstraints(minWidth: 20, minHeight: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? Colors.white : const Color(0xFFE3E2E8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${item.count}',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: selected ? _orange : Colors.black54)),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class OrderTabItem {
  final String label;
  final IconData icon;
  final int count;
  const OrderTabItem(this.label, this.icon, this.count);
}

// ---------- order_progress_tracker.dart ----------
/// Tracker 3 langkah (ikon bulat + garis penghubung + label).
class OrderProgressTracker extends StatelessWidget {
  final OrderStatus status;
  const OrderProgressTracker({super.key, required this.status});

  static const _orange = Color(0xFFF29A0C);
  static const _green = Color(0xFF2E9E4F);
  static const _grey = Color(0xFFD9D9DE);

  @override
  Widget build(BuildContext context) {
    late final List<_Step> steps;
    late final int done; // jumlah langkah aktif
    late final Color color;

    switch (status) {
      case OrderStatus.diproses:
        steps = const [
          _Step(Icons.shopping_cart_outlined, 'Pesanan\nDiterima'),
          _Step(Icons.inventory_2_outlined, 'Sedang\nDiproses'),
          _Step(Icons.check, 'Siap Dikirim'),
        ];
        done = 1;
        color = _orange;
        break;
      case OrderStatus.dikirim:
        steps = const [
          _Step(Icons.shopping_cart_outlined, 'Pesanan\nDiterima'),
          _Step(Icons.inventory_2_outlined, 'Sedang\nDikirim'),
          _Step(Icons.check, 'Sampai Tujuan'),
        ];
        done = 2;
        color = _orange;
        break;
      case OrderStatus.selesai:
        steps = const [
          _Step(Icons.shopping_cart_outlined, 'Pesanan\nDiterima'),
          _Step(Icons.check, 'Dikirim'),
          _Step(Icons.check, 'Selesai'),
        ];
        done = 3;
        color = _green;
        break;
      case OrderStatus.dibatalkan:
        steps = const [
          _Step(Icons.shopping_cart_outlined, 'Pesanan\nDiterima'),
          _Step(Icons.close, 'Dibatalkan'),
        ];
        done = 2;
        color = Colors.red;
        break;
    }

    return Column(
      children: [
        Row(
          children: [
            for (int i = 0; i < steps.length; i++) ...[
              _circle(steps[i].icon, i < done, color),
              if (i < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: i < done - 1
                        ? color.withOpacity(.6)
                        : _grey,
                  ),
                ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < steps.length; i++)
              Expanded(
                child: Text(
                  steps[i].label,
                  textAlign: i == 0
                      ? TextAlign.left
                      : (i == steps.length - 1
                          ? TextAlign.right
                          : TextAlign.center),
                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.25,
                    fontWeight:
                        i < done ? FontWeight.w700 : FontWeight.w400,
                    color: i < done ? Colors.black87 : Colors.black45,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _circle(IconData icon, bool active, Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: active ? color : _grey,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 17, color: active ? Colors.white : Colors.black54),
    );
  }
}

class _Step {
  final IconData icon;
  final String label;
  const _Step(this.icon, this.label);
}

// ---------- order_card.dart ----------
class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;

  const OrderCard({super.key, required this.order, this.onTap});

  static const _orange = Color(0xFFF29A0C);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(.06),
                blurRadius: 14,
                offset: const Offset(0, 4)),
          ],
        ),
        child: LayoutBuilder(builder: (context, c) {
          final wide = c.maxWidth >= 560;
          return wide ? _wideLayout() : _compactLayout();
        }),
      ),
    );
  }

  // Tampilan lebar (tablet / web) seperti desain.
  Widget _wideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _thumb(),
        const SizedBox(width: 14),
        SizedBox(width: 170, child: _info()),
        const SizedBox(width: 16),
        Expanded(child: OrderProgressTracker(status: order.status)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Icon(Icons.chevron_right, color: Colors.black87),
            const SizedBox(height: 28),
            _detailButton(),
          ],
        ),
      ],
    );
  }

  // Tampilan HP.
  Widget _compactLayout() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _thumb(),
            const SizedBox(width: 12),
            Expanded(child: _info()),
            const Icon(Icons.chevron_right, color: Colors.black87),
          ],
        ),
        const SizedBox(height: 14),
        OrderProgressTracker(status: order.status),
        const SizedBox(height: 12),
        Align(alignment: Alignment.centerRight, child: _detailButton()),
      ],
    );
  }

  Widget _thumb() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.asset(
        order.image,
        width: 82,
        height: 92,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 82,
          height: 92,
          color: const Color(0xFFEFE3D0),
          child: const Icon(Icons.image_outlined, color: Colors.brown),
        ),
      ),
    );
  }

  Widget _info() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('No. Pesanan',
            style: TextStyle(fontSize: 12, color: Colors.black45)),
        const SizedBox(height: 2),
        Text(order.id,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E1E1E))),
        const SizedBox(height: 6),
        _meta(Icons.calendar_today_outlined, order.date),
        const SizedBox(height: 4),
        _meta(Icons.inventory_2_outlined, '${order.itemCount} Produk'),
        const SizedBox(height: 8),
        _statusChip(),
      ],
    );
  }

  Widget _meta(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 14, color: Colors.black45),
          const SizedBox(width: 6),
          Flexible(
            child: Text(text,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ),
        ],
      );

  Widget _statusChip() {
    late final String label;
    late final IconData icon;
    late final Color fg;
    late final Color bg;
    switch (order.status) {
      case OrderStatus.diproses:
        label = 'Diproses';
        icon = Icons.autorenew;
        fg = const Color(0xFF2E9E4F);
        bg = const Color(0xFFD9F2DF);
        break;
      case OrderStatus.dikirim:
        label = 'Dikirim';
        icon = Icons.local_shipping_outlined;
        fg = const Color(0xFF1E88E5);
        bg = const Color(0xFFDCEEFD);
        break;
      case OrderStatus.selesai:
        label = 'Selesai';
        icon = Icons.check_circle_outline;
        fg = const Color(0xFF2E9E4F);
        bg = const Color(0xFFD9F2DF);
        break;
      case OrderStatus.dibatalkan:
        label = 'Dibatalkan';
        icon = Icons.cancel_outlined;
        fg = Colors.red;
        bg = const Color(0xFFFDE0E0);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: fg)),
        ],
      ),
    );
  }

  Widget _detailButton() {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: _orange,
        side: const BorderSide(color: _orange, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Lihat Detail',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          SizedBox(width: 40),
          Icon(Icons.chevron_right, size: 16),
        ],
      ),
    );
  }
}

// ---------- order_help_banner.dart ----------
class OrderHelpBanner extends StatelessWidget {
  final VoidCallback? onWhatsAppTap;
  const OrderHelpBanner({super.key, this.onWhatsAppTap});

  static const _orange = Color(0xFFF29A0C);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBEFD9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration:
                const BoxDecoration(color: _orange, shape: BoxShape.circle),
            child: const Icon(Icons.info_outline, size: 15, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('Butuh bantuan? Hubungi kami melalui ',
                    style: TextStyle(fontSize: 12, color: Colors.black87)),
                GestureDetector(
                  onTap: onWhatsAppTap,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('WhatsApp',
                          style: TextStyle(
                              fontSize: 12,
                              color: _orange,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline)),
                      SizedBox(width: 3),
                      Icon(Icons.open_in_new, size: 12, color: _orange),
                    ],
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

// ---------- order_view.dart ----------
class OrderView extends StatefulWidget {
  const OrderView({super.key});

  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView> {
  int _tab = 0;

  // Data contoh. Ganti dengan data dari API / Firestore.
  final List<OrderModel> _orders = const [
    OrderModel(
      id: '#BRK20250423-001',
      date: '23 Apr 2025, 14:32',
      itemCount: 2,
      status: OrderStatus.diproses,
      image: 'assets/images/batik1.png',
    ),
    OrderModel(
      id: '#BRK20250412-002',
      date: '12 Apr 2025, 09:20',
      itemCount: 1,
      status: OrderStatus.dikirim,
      image: 'assets/images/batik2.png',
    ),
    OrderModel(
      id: '#BRK20250331-003',
      date: '31 Mar 2025, 16:10',
      itemCount: 1,
      status: OrderStatus.selesai,
      image: 'assets/images/batik3.png',
    ),
  ];

  static const _filters = <OrderStatus?>[
    null,
    OrderStatus.diproses,
    OrderStatus.dikirim,
    OrderStatus.selesai,
    OrderStatus.dibatalkan,
  ];

  int _count(OrderStatus? s) =>
      s == null ? _orders.length : _orders.where((o) => o.status == s).length;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      OrderTabItem('Semua', Icons.shopping_bag_outlined, _count(null)),
      OrderTabItem('Diproses', Icons.access_time, _count(OrderStatus.diproses)),
      OrderTabItem('Dikirim', Icons.local_shipping_outlined,
          _count(OrderStatus.dikirim)),
      OrderTabItem(
          'Selesai', Icons.check_circle_outline, _count(OrderStatus.selesai)),
      OrderTabItem(
          'Dibatalkan', Icons.refresh, _count(OrderStatus.dibatalkan)),
    ];

    final selected = _filters[_tab];
    final list = selected == null
        ? _orders
        : _orders.where((o) => o.status == selected).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FD),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const OrderHeader(),
            const SizedBox(height: 10),
            const OrderBanner(),
            const SizedBox(height: 18),
            OrderFilterTabs(
              items: tabs,
              selectedIndex: _tab,
              onSelected: (i) => setState(() => _tab = i),
            ),
            const SizedBox(height: 18),
            if (list.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Text('Belum ada pesanan',
                      style: TextStyle(color: Colors.black45)),
                ),
              )
            else
              for (final o in list) ...[
                OrderCard(
                  order: o,
                  onTap: () {
                    // TODO: Navigator.push ke halaman detail pesanan
                  },
                ),
                const SizedBox(height: 14),
              ],
            const SizedBox(height: 4),
            OrderHelpBanner(
              onWhatsAppTap: () {
                // TODO: launchUrl(Uri.parse('https://wa.me/62xxxxxxxxxx'));
              },
            ),
          ],
        ),
      ),
    );
  }
}