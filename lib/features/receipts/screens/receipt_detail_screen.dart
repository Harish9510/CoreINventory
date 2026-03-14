import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models.dart';
import '../../../theme/app_colors.dart';

class ReceiptDetailScreen extends StatefulWidget {
  final String operationId;
  const ReceiptDetailScreen({super.key, required this.operationId});

  @override
  State<ReceiptDetailScreen> createState() => _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends State<ReceiptDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final store = context.watch<InventoryStore>();
    final op = store.operations.firstWhere(
      (o) => o.id == widget.operationId,
      orElse: () => StockOperation(
        id: '',
        reference: 'Unknown',
        type: OperationType.receipt,
        status: OperationStatus.canceled,
        scheduledDate: DateTime.now(),
        products: {},
      ),
    );

    if (op.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Receipt Details')),
        body: const Center(child: Text('Operation removed or not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Receipt ${op.reference}'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Stepper
            _buildStepper(op.status),
            const SizedBox(height: 20),

            // Action Buttons
            _buildActionButtons(op, store),
            const SizedBox(height: 24),

            // Info Card
            _buildInfoCard(op),
            const SizedBox(height: 24),

            // Products Section
            _buildProductsSection(op, store),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper(OperationStatus status) {
    int currentIndex = 0;
    if (status == OperationStatus.ready) currentIndex = 1;
    if (status == OperationStatus.done) currentIndex = 2;
    if (status == OperationStatus.canceled) currentIndex = -1;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _stepItem('Draft', currentIndex >= 0, currentIndex == 0),
          _stepDivider(currentIndex >= 1),
          _stepItem('Ready', currentIndex >= 1, currentIndex == 1),
          _stepDivider(currentIndex >= 2),
          _stepItem('Done', currentIndex >= 2, currentIndex == 2),
        ],
      ),
    );
  }

  Widget _stepItem(String label, bool isCompleted, bool isActive) {
    final color = isCompleted ? AppColors.primary : AppColors.border;
    final textColor = isActive
        ? AppColors.primary
        : (isCompleted ? AppColors.textPrimary : AppColors.textLight);

    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? AppColors.primaryLight.withOpacity(0.2)
                : Colors.transparent,
            border: Border.all(color: color, width: 2),
          ),
          child: isCompleted && !isActive
              ? Icon(Icons.check, size: 16, color: color)
              : (isActive
                    ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isActive || isCompleted
                ? FontWeight.w600
                : FontWeight.w400,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _stepDivider(bool isCompleted) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        color: isCompleted ? AppColors.primary : AppColors.border,
      ),
    );
  }

  Widget _buildActionButtons(StockOperation op, InventoryStore store) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (op.status == OperationStatus.draft)
            _actionBtn('Validate', Iconsax.tick_circle, AppColors.primary, () {
              store.validateOperation(op.id);
            }),
          if (op.status == OperationStatus.ready)
            _actionBtn('Validate', Iconsax.tick_circle, AppColors.success, () {
              store.markDone(op.id);
            }),
          if (op.status != OperationStatus.draft) const SizedBox(width: 12),
          _actionBtn('Print', Iconsax.printer, AppColors.info, () {
            // Print logic placeholder
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Printing receipt...')),
            );
          }),
          if (op.status != OperationStatus.done &&
              op.status != OperationStatus.canceled) ...[
            const SizedBox(width: 12),
            _actionBtn('Cancel', Iconsax.close_circle, AppColors.error, () {
              showDialog(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Cancel Operation'),
                  content: const Text(
                    'Are you sure you want to cancel this receipt?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () {
                        store.cancelOperation(op.id);
                        Navigator.pop(c);
                      },
                      child: const Text(
                        'Yes, Cancel',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              );
            }, isOutlined: true),
          ],
        ],
      ),
    );
  }

  Widget _actionBtn(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isOutlined = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isOutlined ? Colors.transparent : color,
          border: isOutlined ? Border.all(color: color) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isOutlined ? color : Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isOutlined ? color : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(StockOperation op) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
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
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(op.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  op.status.name.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _getStatusColor(op.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _infoField('Receive From', op.partner ?? 'Unknown'),
              ),
              Expanded(
                child: _infoField(
                  'Schedule Date',
                  '${op.scheduledDate.year}-${op.scheduledDate.month.toString().padLeft(2, '0')}-${op.scheduledDate.day.toString().padLeft(2, '0')}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _infoField('Responsible', op.responsible ?? 'System'),
        ],
      ),
    );
  }

  Widget _infoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 4),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 2),
            ),
          ),
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductsSection(StockOperation op, InventoryStore store) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Products',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.background.withOpacity(0.5),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Product',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Quantity',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Product Rows
          if (op.products.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No products added',
                  style: GoogleFonts.inter(color: AppColors.textLight),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: op.products.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) {
                final entry = op.products.entries.elementAt(index);
                final product = store.getProduct(entry.key);
                final name = product?.name ?? 'Unknown';
                final sku = product?.sku ?? entry.key;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          '[$sku] $name',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${entry.value}',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

          const Divider(height: 1, color: AppColors.border),

          if (op.status == OperationStatus.draft)
            InkWell(
              onTap: () {
                // Future enhancement: Add product dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Add product functionality placeholder for Draft operations.',
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Add new product',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(OperationStatus status) {
    switch (status) {
      case OperationStatus.draft:
        return AppColors.textLight;
      case OperationStatus.waiting:
        return AppColors.error;
      case OperationStatus.ready:
        return AppColors.warning;
      case OperationStatus.done:
        return AppColors.success;
      case OperationStatus.canceled:
        return AppColors.error;
    }
  }
}
