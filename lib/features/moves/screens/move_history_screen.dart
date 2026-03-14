import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models.dart';
import '../../../theme/app_colors.dart';

class MoveHistoryScreen extends StatefulWidget {
  const MoveHistoryScreen({super.key});

  @override
  State<MoveHistoryScreen> createState() => _MoveHistoryScreenState();
}

class _MoveHistoryScreenState extends State<MoveHistoryScreen> {
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search moves...',
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : Text(
                'Move History',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  color: AppColors.primary,
                ),
              ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Iconsax.search_normal),
            color: AppColors.primary,
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchCtrl.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: Consumer<InventoryStore>(
        builder: (context, store, _) {
          var moves = store.getMoveHistory();

          if (_searchQuery.isNotEmpty) {
            final q = _searchQuery.toLowerCase();
            moves = moves.where((m) {
              final op = m['operation'] as StockOperation;
              final pName = m['productName'].toString().toLowerCase();
              final pSku = m['productSku'].toString().toLowerCase();
              return op.reference.toLowerCase().contains(q) ||
                  (op.partner?.toLowerCase().contains(q) ?? false) ||
                  pName.contains(q) ||
                  pSku.contains(q);
            }).toList();
          }

          if (moves.isEmpty) return _emptyState();

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    AppColors.background.withOpacity(0.5),
                  ),
                  columnSpacing: 24,
                  columns: [
                    _dataColumn('Reference'),
                    _dataColumn('Product'),
                    _dataColumn('Date'),
                    _dataColumn('Contact'),
                    _dataColumn('From'),
                    _dataColumn('To'),
                    _dataColumn('Quantity'),
                    _dataColumn('Status'),
                  ],
                  rows: moves.map((m) {
                    final op = m['operation'] as StockOperation;
                    final qty = m['quantity'] as int;
                    final pName = m['productName'];
                    final pSku = m['productSku'];

                    Color rowColor = Colors.transparent;
                    if (op.type == OperationType.receipt)
                      rowColor = AppColors.successLight.withOpacity(0.2);
                    if (op.type == OperationType.delivery)
                      rowColor = AppColors.errorLight.withOpacity(0.2);

                    return DataRow(
                      color: MaterialStateProperty.all(rowColor),
                      cells: [
                        DataCell(
                          Text(
                            op.reference,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        DataCell(Text('[$pSku] $pName')),
                        DataCell(
                          Text(
                            '${op.scheduledDate.year}-${op.scheduledDate.month}-${op.scheduledDate.day}',
                          ),
                        ),
                        DataCell(Text(op.partner ?? '')),
                        DataCell(Text(op.sourceLocation ?? '')),
                        DataCell(Text(op.destinationLocation ?? '')),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _getDirectionIcon(op.type),
                              const SizedBox(width: 4),
                              Text(
                                '$qty',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _getDirectionColor(op.type),
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(_statusBadge(op.status)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  DataColumn _dataColumn(String label) {
    return DataColumn(
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.infoLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.arrow_swap_horizontal,
              size: 48,
              color: AppColors.info,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No move history found',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDirectionColor(OperationType type) {
    if (type == OperationType.receipt) return AppColors.success;
    if (type == OperationType.delivery) return AppColors.error;
    return AppColors.textPrimary;
  }

  Icon _getDirectionIcon(OperationType type) {
    if (type == OperationType.receipt)
      return const Icon(
        Icons.arrow_downward,
        size: 14,
        color: AppColors.success,
      );
    if (type == OperationType.delivery)
      return const Icon(Icons.arrow_upward, size: 14, color: AppColors.error);
    if (type == OperationType.transfer)
      return const Icon(
        Icons.swap_horiz,
        size: 14,
        color: AppColors.textPrimary,
      );
    return const Icon(Icons.calculate, size: 14, color: AppColors.textPrimary);
  }

  Widget _statusBadge(OperationStatus status) {
    Color color;
    Color bgColor;

    switch (status) {
      case OperationStatus.draft:
        color = AppColors.textSecondary;
        bgColor = AppColors.border;
        break;
      case OperationStatus.waiting:
        color = AppColors.error;
        bgColor = AppColors.errorLight;
        break;
      case OperationStatus.ready:
        color = AppColors.warning;
        bgColor = AppColors.warningLight;
        break;
      case OperationStatus.done:
        color = AppColors.success;
        bgColor = AppColors.successLight;
        break;
      case OperationStatus.canceled:
        color = AppColors.textLight;
        bgColor = AppColors.background;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
