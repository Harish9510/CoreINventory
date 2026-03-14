import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/dashboard_widgets.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<_KpiData> _kpis = [
    _KpiData(
      'Total In Stock',
      '1,284',
      Icons.inventory_2_rounded,
      AppColors.primary,
      '+12 today',
    ),
    _KpiData(
      'Low / Out of Stock',
      '23',
      Icons.warning_amber_rounded,
      AppColors.warning,
      '5 critical',
    ),
    _KpiData(
      'Pending Receipts',
      '12',
      Icons.download_rounded,
      AppColors.info,
      'Awaiting',
    ),
    _KpiData(
      'Pending Deliveries',
      '9',
      Icons.local_shipping_rounded,
      AppColors.success,
      'Ready',
    ),
    _KpiData(
      'Transfers Today',
      '5',
      Icons.swap_horiz_rounded,
      AppColors.error,
      'Scheduled',
    ),
  ];

  final List<_ActivityData> _activities = [
    _ActivityData(
      Icons.download_rounded,
      AppColors.info,
      'REC-00142',
      '50 kg Steel Rods · Main Warehouse',
      '2h ago',
      'Done',
    ),
    _ActivityData(
      Icons.local_shipping_rounded,
      AppColors.success,
      'DEL-00088',
      '10 Chairs · Customer #392',
      '3h ago',
      'Ready',
    ),
    _ActivityData(
      Icons.swap_horiz_rounded,
      AppColors.primary,
      'INT-00031',
      'Main Store → Production Rack',
      '5h ago',
      'Waiting',
    ),
    _ActivityData(
      Icons.tune_rounded,
      AppColors.warning,
      'ADJ-00019',
      '3 kg Steel damaged & adjusted',
      '1d ago',
      'Done',
    ),
    _ActivityData(
      Icons.download_rounded,
      AppColors.info,
      'REC-00141',
      '100 units PVC Pipe · Store B',
      '1d ago',
      'Draft',
    ),
    _ActivityData(
      Icons.local_shipping_rounded,
      AppColors.success,
      'DEL-00087',
      '25 Steel Frames · Customer #280',
      '2d ago',
      'Done',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header (Light themed with Primary Gradient accents)
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(28, 52, 28, 28),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting(),
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Inventory Dashboard',
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _HeaderChip(
                        icon: Icons.notifications_outlined,
                        color: AppColors.primary,
                        label: '3',
                      ),
                      const SizedBox(width: 10),
                      _HeaderChip(
                        icon: Icons.refresh_rounded,
                        color: AppColors.textSecondary,
                        label: null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Summary bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        _SummaryChip(
                          label: 'Warehouses',
                          value: '3',
                          color: AppColors.primary,
                        ),
                        _vDivider(),
                        _SummaryChip(
                          label: 'Products',
                          value: '286',
                          color: AppColors.success,
                        ),
                        _vDivider(),
                        _SummaryChip(
                          label: 'SKUs',
                          value: '1,284',
                          color: AppColors.warning,
                        ),
                        _vDivider(),
                        _SummaryChip(
                          label: 'Alerts',
                          value: '23',
                          color: AppColors.error,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── KPI Cards
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, i) => KpiCard(
                  title: _kpis[i].title,
                  value: _kpis[i].value,
                  icon: _kpis[i].icon,
                  color: _kpis[i].color,
                  subtitle: _kpis[i].subtitle,
                ),
                childCount: _kpis.length,
              ),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 240,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
            ),
          ),

          // ── Filters
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Quick Filters',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const FilterChipRow(
                    label: 'Document Type',
                    options: [
                      'Receipts',
                      'Delivery',
                      'Internal Transfers',
                      'Adjustments',
                    ],
                  ),
                  const SizedBox(height: 16),
                  const FilterChipRow(
                    label: 'Status',
                    options: ['Draft', 'Waiting', 'Ready', 'Done', 'Canceled'],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _DropdownFilter(
                          label: 'Warehouse',
                          icon: Icons.warehouse_rounded,
                          options: [
                            'All Warehouses',
                            'Main Warehouse',
                            'Store B',
                            'Production Floor',
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _DropdownFilter(
                          label: 'Category',
                          icon: Icons.category_rounded,
                          options: [
                            'All Categories',
                            'Raw Materials',
                            'Finished Goods',
                            'Packaging',
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Recent Operations
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Operations',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.open_in_new_rounded, size: 14),
                    label: Text(
                      'View all',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
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
                children: _activities
                    .map(
                      (a) => ActivityItem(
                        icon: a.icon,
                        color: a.color,
                        title: a.title,
                        subtitle: a.subtitle,
                        time: a.time,
                        status: a.status,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 👋';
    if (hour < 17) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }

  Widget _vDivider() => Container(
    width: 1,
    height: 28,
    margin: const EdgeInsets.symmetric(horizontal: 12),
    color: AppColors.border,
  );
}

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String? label;

  const _HeaderChip({required this.icon, required this.color, this.label});

  @override
  Widget build(BuildContext context) {
    final isPrimary = color == AppColors.primary;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.primarySurface : AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isPrimary
                  ? AppColors.primaryLight.withValues(alpha: 0.3)
                  : AppColors.border,
            ),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        if (label != null)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label!,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label, value;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownFilter extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<String> options;

  const _DropdownFilter({
    required this.label,
    required this.icon,
    required this.options,
  });

  @override
  State<_DropdownFilter> createState() => _DropdownFilterState();
}

class _DropdownFilterState extends State<_DropdownFilter> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.options[0];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selected,
              isExpanded: true,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              icon: const Icon(
                Icons.expand_more_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
              onChanged: (v) => setState(() => _selected = v!),
              items: widget.options
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _KpiData {
  final String title, value, subtitle;
  final IconData icon;
  final Color color;
  const _KpiData(this.title, this.value, this.icon, this.color, this.subtitle);
}

class _ActivityData {
  final IconData icon;
  final Color color;
  final String title, subtitle, time, status;
  const _ActivityData(
    this.icon,
    this.color,
    this.title,
    this.subtitle,
    this.time,
    this.status,
  );
}
