import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/dashboard_widgets.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Mock KPI data
  final List<_KpiData> _kpis = [
    _KpiData(
      'Total Products in Stock',
      '1,284',
      Icons.inventory_2_rounded,
      AppColors.primary,
      'Across all warehouses',
    ),
    _KpiData(
      'Low / Out of Stock',
      '23',
      Icons.warning_amber_rounded,
      AppColors.warning,
      '18 low · 5 out of stock',
    ),
    _KpiData(
      'Pending Receipts',
      '12',
      Icons.download_rounded,
      AppColors.accent,
      'Awaiting validation',
    ),
    _KpiData(
      'Pending Deliveries',
      '9',
      Icons.local_shipping_rounded,
      AppColors.success,
      'Ready to dispatch',
    ),
    _KpiData(
      'Internal Transfers',
      '5',
      Icons.swap_horiz_rounded,
      AppColors.danger,
      'Scheduled today',
    ),
  ];

  // Mock recent activity
  final List<_ActivityData> _activities = [
    _ActivityData(
      Icons.download_rounded,
      AppColors.accent,
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
      AppColors.accent,
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
      backgroundColor: AppColors.pageBg,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Inventory Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Real-time overview of your stock operations',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Today · March 14',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── KPI Cards ───────────────────────────
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
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 260,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: MediaQuery.of(context).size.width > 900
                    ? 1.2
                    : 1.1,
              ),
            ),
          ),

          // ── Filters ─────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.filter_list_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Dynamic Filters',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
                      const SizedBox(width: 16),
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

          // ── Recent Activity ─────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Operations',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'View all',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
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
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selected,
              isExpanded: true,
              style: const TextStyle(color: Color(0xFF334155), fontSize: 12),
              icon: const Icon(
                Icons.expand_more_rounded,
                size: 18,
                color: Color(0xFF64748B),
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
