import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/order_controller.dart';
import '../models/order_model.dart';
import '../theme/app_theme.dart';
import 'order_detail_view.dart';

class OrderView extends StatefulWidget {
  const OrderView({super.key});

  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<OrderController>().load(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesanan Saya')),
      body: Consumer<OrderController>(
        builder: (context, controller, _) {
          if (controller.isLoading && controller.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.errorMessage != null && controller.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(controller.errorMessage!, textAlign: TextAlign.center),
                  TextButton(
                    onPressed: () => controller.load(refresh: true),
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            );
          }
          if (controller.orders.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => controller.load(refresh: true),
              child: ListView(
                children: const [
                  SizedBox(height: 180),
                  Center(child: Text('Belum ada pesanan')),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => controller.load(refresh: true),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.orders.length + 1,
              itemBuilder: (context, index) {
                if (index == controller.orders.length) {
                  if (!controller.canLoadMore) {
                    return const SizedBox(height: 24);
                  }
                  return Center(
                    child: TextButton(
                      onPressed: () => controller.load(),
                      child: const Text('Muat pesanan berikutnya'),
                    ),
                  );
                }
                final order = controller.orders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      order.number,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(orderStatusLabel(order.status)),
                          if (order.createdAt != null)
                            Text(
                              '${order.createdAt!.toLocal().day}/${order.createdAt!.toLocal().month}/${order.createdAt!.toLocal().year}',
                            ),
                          Text(
                            formatRupiah(order.total),
                            style: const TextStyle(color: AppTheme.textPrimary),
                          ),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailView(
                          orderId: order.id,
                          initialOrder: order,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

String orderStatusLabel(String status) => switch (status) {
  'pending_payment' => 'Menunggu pembayaran',
  'paid' => 'Sudah dibayar',
  'processing' => 'Diproses',
  'packing' => 'Dikemas',
  'shipped' => 'Dikirim',
  'completed' => 'Selesai',
  'cancelled' => 'Dibatalkan',
  _ => status,
};
