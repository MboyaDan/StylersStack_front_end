import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/orders_skeleton.dart';
import '../../widgets/PulsingStatusChip.dart';
import 'package:go_router/go_router.dart'; // Needed for context.push

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
          () => context.read<OrderProvider>().fetchOrders(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text("My Orders"),
        centerTitle: true,
      ),
      body: orderProvider.isLoadingOrders
          ? const OrdersSkeleton() // Shimmer loader
          : orderProvider.orders.isEmpty
          ? const Center(
        child: Text("No orders yet."),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orderProvider.orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final order = orderProvider.orders[index];

          return InkWell(
            onTap: () {
              context.push(
                '/orderdetailscreen',
                extra: order.id,
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order ID & Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Order #${order.id}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        order.createdAtFormatted,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Status Chip
                  order.status.toLowerCase() == "pending"
                      ? PulsingStatusChip(
                    label: order.status,
                    baseColor: Colors.orange,
                  )
                      : Chip(
                    label:
                    Text(order.status.toUpperCase()),
                    backgroundColor:
                    _statusColor(order.status),
                    labelStyle: const TextStyle(
                        color: Colors.white),
                  ),

                  const SizedBox(height: 8),

                  // Amount
                  Text(
                    "Total: KES ${order.total.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "delivered":
        return Colors.green;
      case "pending":
        return Colors.orange;
      case "cancelled":
        return Colors.red;
      default:
        return AppColors.background;
    }
  }
}
