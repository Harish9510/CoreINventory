import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models.dart';
import '../../../main.dart';
import '../../../core/theme/app_colors.dart';

class StockLedgerScreen extends StatefulWidget {
  const StockLedgerScreen({super.key});

  @override
  State<StockLedgerScreen> createState() => _StockLedgerScreenState();
}

class _StockLedgerScreenState extends State<StockLedgerScreen> {
  OperationType? _filter;

  @override
  void initState() {
    super.initState();
    inventoryStore.addListener(_refresh);
  }

  @override
  void dispose() {
    inventoryStore.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final logs = _filter == null
        ? inventoryStore.operations
        : inventoryStore.getOperationsByType(_filter!);

    return Scaffold(
      appBar: AppBar(title: const Text('Stock Ledger')),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                _chip('All', null),
                _chip('Receipts', OperationType.receipt),
                _chip('Deliveries', OperationType.delivery),
                _chip('Transfers', OperationType.transfer),
                _chip('Adjustments', OperationType.adjustment),
              ],
            ),
          ),

          Expanded(
            child: logs.isEmpty
                ? Center(
                    child: Text(
                      'No records found',
                      style: GoogleFonts.inter(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: logs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _logTile(logs[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, OperationType? type) {
    final isActive = _filter == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isActive,
        onSelected: (_) => setState(() => _filter = type),
        selectedColor: AppColors.primary,
        labelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: isActive ? Colors.white : AppColors.textSecondary,
        ),
        showCheckmark: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(
          color: isActive ? AppColors.primary : AppColors.border,
        ),
      ),
    );
  }

  Widget _logTile(StockOperation op) {
    IconData icon;
    Color color;
    String title;
    String subtitle;

    switch (op.type) {
      case OperationType.receipt:
        icon = Iconsax.document_download;
        color = AppColors.success;
        title = 'Receipt';
        subtitle =
            'From ${op.partner ?? "Unknown"} → ${op.destinationLocation ?? ""}';
        break;
      case OperationType.delivery:
        icon = Iconsax.truck_fast;
        color = AppColors.warning;
        title = 'Delivery';
        subtitle =
            'To ${op.partner ?? "Walk-in"} from ${op.sourceLocation ?? ""}';
        break;
      case OperationType.transfer:
        icon = Iconsax.arrow_swap_horizontal;
        color = const Color(0xFF8B5CF6);
        title = 'Transfer';
        subtitle = '${op.sourceLocation} → ${op.destinationLocation}';
        break;
      case OperationType.adjustment:
        icon = Iconsax.edit_2;
        color = AppColors.error;
        title = 'Adjustment';
        subtitle = '${op.sourceLocation ?? ""} • ${op.partner ?? ""}';
        break;
    }

    final productNames = op.products.entries
        .map((e) {
          final p = inventoryStore.getProduct(e.key);
          final sign = e.value >= 0 ? '+' : '';
          return '${p?.name ?? e.key}: $sign${e.value}';
        })
        .join(', ');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      op.reference,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  productNames,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${op.scheduledDate.day}/${op.scheduledDate.month}',
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}
