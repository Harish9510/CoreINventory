import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../models.dart';
import '../../../../core/theme/app_colors.dart';
import 'new_receipt_screen.dart';

class ReceiptListScreen extends StatefulWidget {
  const ReceiptListScreen({super.key});

  @override
  State<ReceiptListScreen> createState() => _ReceiptListScreenState();
}

class _ReceiptListScreenState extends State<ReceiptListScreen> {
  final List<StockOperation> _receipts = DummyData.operations
      .where((op) => op.type == OperationType.receipt)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipts'),
        actions: [
          IconButton(icon: const Icon(Iconsax.search_normal), onPressed: () {}),
          IconButton(icon: const Icon(Iconsax.filter), onPressed: () {}),
        ],
      ),
      body: _receipts.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _receipts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final receipt = _receipts[index];
                return _buildOperationCard(context, receipt);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewReceiptScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: const Text('New Receipt', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.document_download,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No receipts found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('Create a new receipt to record incoming goods.'),
        ],
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
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              _buildStatusBadge(op.status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Iconsax.user,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                op.partner ?? 'Unknown Supplier',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Iconsax.calendar,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                "${op.scheduledDate.day}/${op.scheduledDate.month}/${op.scheduledDate.year}",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${op.products.length} Products",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const Icon(Iconsax.arrow_right_3, size: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OperationStatus status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case OperationStatus.done:
        bgColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        label = 'Done';
        break;
      case OperationStatus.waiting:
        bgColor = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        label = 'Waiting';
        break;
      case OperationStatus.ready:
        bgColor = AppColors.primary.withOpacity(0.1);
        textColor = AppColors.primary;
        label = 'Ready';
        break;
      default:
        bgColor = AppColors.textSecondary.withOpacity(0.1);
        textColor = AppColors.textSecondary;
        label = status.name.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
