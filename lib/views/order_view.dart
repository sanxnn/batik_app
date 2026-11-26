import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/order_controller.dart';
import '../theme/app_spacing.dart';
import '../widgets/common/app_app_bar.dart';
import '../widgets/common/order_card.dart';
import '../widgets/common/status_chip.dart';
import '../widgets/common/app_state_view.dart';
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
      appBar: const AppAppBar(title: 'Pesanan Saya'),
      body: Consumer<OrderController>(
        builder: (context, controller, _) {
          if (controller.isLoading && controller.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.errorMessage != null && controller.orders.isEmpty) {
            return AppStateView(
              icon: Icons.cloud_off_outlined,
              title: 'Pesanan belum termuat',
              message: controller.errorMessage!,
              actionLabel: 'Coba lagi',
              onAction: () => controller.load(refresh: true),
            );
          }
          if (controller.orders.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => controller.load(refresh: true),
              child: ListView(
                children: const [
                  SizedBox(height: AppSpacing.emptyStateTop),
                  AppStateView(
                    icon: Icons.receipt_long_outlined,
                    title: 'Belum ada pesanan',
                    message: 'Pesanan yang kamu buat akan muncul di sini.',
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => controller.load(refresh: true),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.page),
              itemCount: controller.orders.length + 1,
              itemBuilder: (context, index) {
                if (index == controller.orders.length) {
                  if (!controller.canLoadMore) {
                    return const SizedBox(height: AppSpacing.xl);
                  }
                  return Center(
                    child: TextButton(
                      onPressed: () => controller.load(),
                      child: const Text('Muat pesanan berikutnya'),
                    ),
                  );
                }
                final order = controller.orders[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: OrderCard(
                    order: order,
                    statusLabel: orderStatusLabel(order.status),
                    statusTone: orderStatusTone(order.status),
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

AppStatusTone orderStatusTone(String status) => switch (status) {
  'completed' => AppStatusTone.success,
  'shipped' => AppStatusTone.info,
  'cancelled' => AppStatusTone.danger,
  _ => AppStatusTone.warning,
};
