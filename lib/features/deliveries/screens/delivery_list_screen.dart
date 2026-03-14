import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models.dart';
import '../../../theme/app_colors.dart';
import 'new_delivery_screen.dart';
import 'delivery_detail_screen.dart';

enum DeliveryViewMode { list, kanban }

class DeliveryListScreen extends StatefulWidget {
  const DeliveryListScreen({super.key});

  @override
  State<DeliveryListScreen> createState() => _DeliveryListScreenState();
}

class _DeliveryListScreenState extends State<DeliveryListScreen> {
  DeliveryViewMode _viewMode = DeliveryViewMode.list;
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
                  hintText: 'Search deliveries...',
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : Text(
                'Delivery',
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
          IconButton(
            icon: Icon(
              Iconsax.task_square,
              color: _viewMode == DeliveryViewMode.list
                  ? AppColors.primary
                  : AppColors.textLight,
            ),
            onPressed: () => setState(() => _viewMode = DeliveryViewMode.list),
          ),
          IconButton(
            icon: Icon(
              Iconsax.data,
              color: _viewMode == DeliveryViewMode.kanban
                  ? AppColors.primary
                  : AppColors.textLight,
            ),
            onPressed: () =>
                setState(() => _viewMode = DeliveryViewMode.kanban),
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
          var deliveries = store.getOperationsByType(OperationType.delivery);

          if (_searchQuery.isNotEmpty) {
            final q = _searchQuery.toLowerCase();
            deliveries = deliveries
                .where(
                  (op) =>
                      op.reference.toLowerCase().contains(q) ||
                      (op.partner?.toLowerCase().contains(q) ?? false),
                )
                .toList();
          }

          if (deliveries.isEmpty) return _emptyState();

          return _viewMode == DeliveryViewMode.list
              ? _buildListView(deliveries)
              : _buildKanbanView(deliveries);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewDeliveryScreen()),
        ),
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: const Icon(Iconsax.truck, color: Colors.white),
        label: Text(
          'New',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // ==== Views ====

  Widget _buildListView(List<StockOperation> deliveries) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(AppColors.background),
          columnSpacing: 24,
          columns: [
            _dataColumn('Reference'),
            _dataColumn('From'),
            _dataColumn('To'),
            _dataColumn('Contact'),
            _dataColumn('Schedule date'),
            _dataColumn('Status'),
          ],
          rows: deliveries.map((op) {
            return DataRow(
              cells: [
                DataCell(
                  InkWell(
                    onTap: () => _goToDetail(op.id),
                    child: Text(
                      op.reference,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                DataCell(Text(op.sourceLocation ?? '')),
                DataCell(Text(op.destinationLocation ?? '')),
                DataCell(Text(op.partner ?? '')),
                DataCell(
                  Text(
                    '${op.scheduledDate.year}-${op.scheduledDate.month.toString().padLeft(2, '0')}-${op.scheduledDate.day.toString().padLeft(2, '0')}',
                  ),
                ),
                DataCell(_statusBadge(op.status, isTable: true)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  DataColumn _dataColumn(String label) {
    return DataColumn(
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildKanbanView(List<StockOperation> deliveries) {
    // Group by status
    final draft = deliveries
        .where((op) => op.status == OperationStatus.draft)
        .toList();
    final waiting = deliveries
        .where((op) => op.status == OperationStatus.waiting)
        .toList();
    final ready = deliveries
        .where((op) => op.status == OperationStatus.ready)
        .toList();
    final done = deliveries
        .where((op) => op.status == OperationStatus.done)
        .toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kanbanColumn('Draft', draft),
          _kanbanColumn('Waiting', waiting),
          _kanbanColumn('Ready', ready),
          _kanbanColumn('Done', done),
        ],
      ),
    );
  }

  Widget _kanbanColumn(String title, List<StockOperation> ops) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${ops.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: ops.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final op = ops[index];
                return InkWell(
                  onTap: () => _goToDetail(op.id),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          op.reference,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          op.partner ?? 'Unknown',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${op.scheduledDate.year}-${op.scheduledDate.month}-${op.scheduledDate.day}',
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _goToDetail(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DeliveryDetailScreen(operationId: id)),
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
              Iconsax.truck_fast,
              size: 48,
              color: AppColors.info,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No deliveries found',
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

  Widget _statusBadge(OperationStatus status, {bool isTable = false}) {
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
      padding: EdgeInsets.symmetric(
        horizontal: isTable ? 8 : 10,
        vertical: isTable ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: isTable ? 10 : 9,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
