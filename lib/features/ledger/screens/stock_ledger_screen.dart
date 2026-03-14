import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../models.dart';
import '../../../../core/theme/app_colors.dart';

class StockLedgerScreen extends StatelessWidget {
  const StockLedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = DummyData.operations;

    return Scaffold(
      appBar: AppBar(title: const Text('Stock Ledger')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: logs.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final log = logs[index];
          return ListTile(
            leading: Icon(_getIcon(log.type), color: _getColor(log.type)),
            title: Text(
              log.reference,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${log.type.name.toUpperCase()} - ${log.partner ?? "Internal"}',
            ),
            trailing: Text(
              "${log.scheduledDate.day}/${log.scheduledDate.month}",
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          );
        },
      ),
    );
  }

  IconData _getIcon(OperationType type) {
    switch (type) {
      case OperationType.receipt:
        return Iconsax.document_download;
      case OperationType.delivery:
        return Iconsax.document_upload;
      case OperationType.transfer:
        return Iconsax.shuffle;
      case OperationType.adjustment:
        return Iconsax.edit;
    }
  }

  Color _getColor(OperationType type) {
    switch (type) {
      case OperationType.receipt:
        return AppColors.success;
      case OperationType.delivery:
        return AppColors.warning;
      case OperationType.transfer:
        return AppColors.primary;
      case OperationType.adjustment:
        return AppColors.error;
    }
  }
}
