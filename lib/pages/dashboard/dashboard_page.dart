import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../models.dart';
import '../../features/products/screens/product_list_screen.dart';
import '../../features/receipts/screens/receipt_list_screen.dart';
import '../../features/deliveries/screens/delivery_list_screen.dart';
import '../../features/transfers/screens/transfer_list_screen.dart';
import '../../features/adjustments/screens/adjustment_list_screen.dart';
import '../../features/ledger/screens/stock_ledger_screen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    final store = context.watch<InventoryStore>();

    // Calculated stats
    final totalProducts = store.products.length;
    final totalStock = store.products.fold(0, (sum, p) => sum + p.totalStock);
    final lowStockCount = store.products
        .where((p) => p.totalStock > 0 && p.totalStock <= p.reorderPoint)
        .length;
    final outOfStockCount = store.products
        .where((p) => p.totalStock == 0)
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Easy Inventory',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -1,
                        ),
                      ),
                      Text(
                        'Operations Dashboard',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF818CF8),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF818CF8).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Iconsax.box,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── KPI Cards Grid ──
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.25,
              children: [
                _buildKpiCard(
                  'Total Products',
                  totalProducts.toString(),
                  Iconsax.box,
                  const Color(0xFF818CF8),
                ),
                _buildKpiCard(
                  'Total Stock',
                  totalStock.toString(),
                  Iconsax.grid_5,
                  const Color(0xFF10B981),
                ),
                _buildKpiCard(
                  'Low Stock',
                  lowStockCount.toString(),
                  Iconsax.info_circle,
                  const Color(0xFFF59E0B),
                ),
                _buildKpiCard(
                  'Out of Stock',
                  outOfStockCount.toString(),
                  Iconsax.danger,
                  const Color(0xFFEF4444),
                ),
              ],
            ),
          ),

          // ── Quick Actions ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Text(
                'Quick Actions',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid.count(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
              children: [
                _buildActionTile(
                  context,
                  'Products',
                  Iconsax.box,
                  const Color(0xFF6366F1),
                  const ProductListScreen(),
                ),
                _buildActionTile(
                  context,
                  'Receipts',
                  Iconsax.document_download,
                  const Color(0xFF10B981),
                  const ReceiptListScreen(),
                ),
                _buildActionTile(
                  context,
                  'Deliveries',
                  Iconsax.truck_fast,
                  const Color(0xFFF59E0B),
                  const DeliveryListScreen(),
                ),
                _buildActionTile(
                  context,
                  'Transfers',
                  Iconsax.arrow_swap_horizontal,
                  const Color(0xFF8B5CF6),
                  const TransferListScreen(),
                ),
                _buildActionTile(
                  context,
                  'Adjustments',
                  Iconsax.edit_2,
                  const Color(0xFFEF4444),
                  const AdjustmentListScreen(),
                ),
                _buildActionTile(
                  context,
                  'Ledger',
                  Iconsax.document_text,
                  const Color(0xFF3B82F6),
                  const StockLedgerScreen(),
                ),
              ],
            ),
          ),

          // ── Recent Activity ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Activity',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'View All',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF818CF8),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildActivityItem(store.operations[index]),
                childCount: store.operations.length > 5
                    ? 5
                    : store.operations.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    Widget screen,
  ) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(StockOperation op) {
    IconData icon;
    Color color;
    switch (op.type) {
      case OperationType.receipt:
        icon = Iconsax.document_download;
        color = const Color(0xFF10B981);
        break;
      case OperationType.delivery:
        icon = Iconsax.truck_fast;
        color = const Color(0xFFF59E0B);
        break;
      case OperationType.transfer:
        icon = Iconsax.arrow_swap_horizontal;
        color = const Color(0xFF8B5CF6);
        break;
      case OperationType.adjustment:
        icon = Iconsax.edit_2;
        color = const Color(0xFFEF4444);
        break;
    }

    final bool isDone = op.status == OperationStatus.done;
    final statusColor = isDone ? AppColors.success : AppColors.warning;
    final statusBg = isDone ? AppColors.successLight : AppColors.warningLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  op.reference,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  op.partner ?? 'Internal Move',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              op.status.name,
              style: GoogleFonts.inter(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
