import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../models.dart';
import '../../../../core/theme/app_colors.dart';
import 'new_transfer_screen.dart';

class TransferListScreen extends StatelessWidget {
  const TransferListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transfers = DummyData.operations
        .where((op) => op.type == OperationType.transfer)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Internal Transfers')),
      body: transfers.isEmpty
          ? const Center(child: Text('No transfers found'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: transfers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final t = transfers[index];
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
                      Text(
                        t.reference,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            t.sourceLocation ?? 'N/A',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(Iconsax.arrow_right_1, size: 16),
                          ),
                          Text(
                            t.destinationLocation ?? 'N/A',
                            style: const TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NewTransferScreen()),
        ),
        label: const Text(
          'New Transfer',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Iconsax.shuffle, color: Colors.white),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
