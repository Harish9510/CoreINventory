import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models.dart';
import '../../../theme/app_colors.dart';

class DeliveryDetailScreen extends StatefulWidget {
  final String operationId;
  const DeliveryDetailScreen({super.key, required this.operationId});

  @override
  State<DeliveryDetailScreen> createState() => _DeliveryDetailScreenState();
}

class _DeliveryDetailScreenState extends State<DeliveryDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final store = context.watch<InventoryStore>();
    final op = store.operations.firstWhere(
      (o) => o.id == widget.operationId,
      orElse: () => StockOperation(
        id: '',
        reference: 'Unknown',
        type: OperationType.delivery,
        status: OperationStatus.canceled,
        scheduledDate: DateTime.now(),
        products: {},
      ),
    );

    if (op.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Delivery Details')),
        body: const Center(child: Text('Operation removed or not found')),
      );
    }

    final stockCheck = store.checkStockAvailability(op);
    final hasStockIssues = stockCheck.containsValue(false);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Delivery ${op.reference}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Stepper (Draft -> Waiting -> Ready -> Done)
            _buildStepper(op.status),
            const SizedBox(height: 20),

            // Stock Alert
            if (hasStockIssues &&
                (op.status == OperationStatus.draft ||
                    op.status == OperationStatus.waiting))
              _buildStockAlert(),

            if (hasStockIssues &&
                (op.status == OperationStatus.draft ||
                    op.status == OperationStatus.waiting))
              const SizedBox(height: 16),

            // Action Buttons
            _buildActionButtons(op, store, hasStockIssues),
            const SizedBox(height: 24),

            // Info Card
            _buildInfoCard(op, store),
            const SizedBox(height: 24),

            // Products Section
            _buildProductsSection(op, store, stockCheck),
          ],
        ),
      ),
    );
  }

  Widget _buildStockAlert() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.warning_2, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Some products are out of stock. Delivery is marked as Waiting.',
              style: GoogleFonts.inter(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper(OperationStatus status) {
    int currentIndex = 0;
    if (status == OperationStatus.waiting) currentIndex = 1;
    if (status == OperationStatus.ready) currentIndex = 2;
    if (status == OperationStatus.done) currentIndex = 3;
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
          _stepItem('Waiting', currentIndex >= 1, currentIndex == 1),
          _stepDivider(currentIndex >= 2),
          _stepItem('Ready', currentIndex >= 2, currentIndex == 2),
          _stepDivider(currentIndex >= 3),
          _stepItem('Done', currentIndex >= 3, currentIndex == 3),
        ],
      ),
    );
  }

  Widget _stepItem(String label, bool isCompleted, bool isActive) {
    Color color = AppColors.border;
    if (isCompleted) {
      if (label == 'Waiting' && isActive)
        color = AppColors.error;
      else
        color = AppColors.primary;
    }

    final textColor = isActive
        ? color
        : (isCompleted ? AppColors.textPrimary : AppColors.textLight);

    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? color.withOpacity(0.2) : Colors.transparent,
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
                            color: color,
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
            fontSize: 11,
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
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        color: isCompleted ? AppColors.primary : AppColors.border,
      ),
    );
  }

  Widget _buildActionButtons(
    StockOperation op,
    InventoryStore store,
    bool hasStockIssues,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // If Draft, Validate will push to Waiting (if stock missing) or Ready (if stock available)
          if (op.status == OperationStatus.draft)
            _actionBtn('Validate', Iconsax.tick_circle, AppColors.primary, () {
              if (hasStockIssues) {
                store.updateOperationStatus(op.id, OperationStatus.waiting);
              } else {
                store.validateOperation(op.id);
              }
            }),

          // If Waiting, user can force validate or check availability
          if (op.status == OperationStatus.waiting)
            _actionBtn(
              'Check Availability',
              Iconsax.refresh,
              AppColors.primary,
              () {
                if (!hasStockIssues) {
                  store.validateOperation(op.id);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Still waiting on products to be in stock.',
                      ),
                    ),
                  );
                }
              },
            ),

          // If Ready, user can Mark Done (Dispatch)
          if (op.status == OperationStatus.ready)
            _actionBtn(
              'Dispatch Delivery',
              Iconsax.truck_fast,
              AppColors.success,
              () {
                store.markDone(op.id);
              },
            ),

          if (op.status != OperationStatus.draft) const SizedBox(width: 12),
          _actionBtn('Print', Iconsax.printer, AppColors.info, () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Printing delivery slip...')),
            );
          }),
          if (op.status != OperationStatus.done &&
              op.status != OperationStatus.canceled) ...[
            const SizedBox(width: 12),
            _actionBtn('Cancel', Iconsax.close_circle, AppColors.error, () {
              showDialog(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Cancel Delivery'),
                  content: const Text(
                    'Are you sure you want to cancel this delivery order?',
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

  Widget _buildInfoCard(StockOperation op, InventoryStore store) {
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
                child: _infoField(
                  'Delivery Address',
                  op.deliveryAddress ?? 'Unknown',
                ),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _infoField('Responsible', op.responsible ?? 'System'),
              ),
              Expanded(child: _dropdownField('Operation Type', op, store)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dropdownField(String label, StockOperation op, InventoryStore store) {
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
          height: 30, // constrain height to match _infoField look roughly
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 2),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: op.operationSubType ?? store.operationSubTypes.first,
              icon: const Icon(
                Icons.arrow_drop_down,
                color: AppColors.primary,
                size: 20,
              ),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              onChanged: op.status != OperationStatus.draft
                  ? null
                  : (String? newValue) {
                      if (newValue != null) {
                        setState(() => op.operationSubType = newValue);
                      }
                    },
              items: store.operationSubTypes.map<DropdownMenuItem<String>>((
                String value,
              ) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
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
          height: 30,
          padding: const EdgeInsets.only(bottom: 4),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 2),
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductsSection(
    StockOperation op,
    InventoryStore store,
    Map<String, bool> stockCheck,
  ) {
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

                final hasStock = stockCheck[entry.key] ?? false;

                return Container(
                  color: !hasStock && op.status != OperationStatus.done
                      ? AppColors.errorLight.withOpacity(0.5)
                      : Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            if (!hasStock && op.status != OperationStatus.done)
                              const Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Icon(
                                  Icons.warning_rounded,
                                  color: AppColors.error,
                                  size: 16,
                                ),
                              ),
                            Expanded(
                              child: Text(
                                '[$sku] $name',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      !hasStock &&
                                          op.status != OperationStatus.done
                                      ? AppColors.error
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
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
                            color:
                                !hasStock && op.status != OperationStatus.done
                                ? AppColors.error
                                : AppColors.primary,
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
        return AppColors.textLight;
    }
  }
}
