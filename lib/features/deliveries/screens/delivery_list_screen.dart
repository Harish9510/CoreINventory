import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../models.dart';
import '../../../../core/theme/app_colors.dart';
import 'new_delivery_screen.dart';

class DeliveryListScreen extends StatefulWidget {
  const DeliveryListScreen({super.key});

  @override
  State<DeliveryListScreen> createState() => _DeliveryListScreenState();
}

class _DeliveryListScreenState extends State<DeliveryListScreen> {
  final List<StockOperation> _deliveries = DummyData.operations
      .where((op) => op.type == OperationType.delivery)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Orders')),
      body: _deliveries.isEmpty
          ? const Center(child: Text('No deliveries found'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _deliveries.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final delivery = _deliveries[index];
                return _buildOperationCard(context, delivery);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewDeliveryScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Iconsax.send_1, color: Colors.white),
        label: const Text(
          'New Delivery',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildOperationCard(BuildContext context, StockOperation op) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                op.reference,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              _buildStatusBadge(op.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Customer: ${op.partner ?? "Walk-in"}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          Text(
            'Source: ${op.sourceLocation ?? "N/A"}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OperationStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status == OperationStatus.ready
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.textSecondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: status == OperationStatus.ready
              ? AppColors.primary
              : AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
