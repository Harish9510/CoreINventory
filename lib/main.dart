import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'models.dart';
import 'features/products/screens/product_list_screen.dart';
import 'features/receipts/screens/receipt_list_screen.dart';
import 'features/deliveries/screens/delivery_list_screen.dart';
import 'features/transfers/screens/transfer_list_screen.dart';
import 'features/adjustments/screens/adjustment_list_screen.dart';
import 'features/ledger/screens/stock_ledger_screen.dart';

final InventoryStore inventoryStore = InventoryStore();

void main() {
  runApp(const EasyInventoryApp());
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/auth_provider.dart';
import 'routes/app_routes.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/signup_page.dart';
import 'pages/app_shell.dart';
import 'theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Replace with your actual Supabase URL and Anon Key
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: const MyApp(),
    ),
  );
}

class EasyInventoryApp extends StatelessWidget {
  const EasyInventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Easy Inventory',
      theme: AppTheme.lightTheme,
      home: const OperationsDashboard(),
    );
  }
}

class OperationsDashboard extends StatefulWidget {
  const OperationsDashboard({super.key});

  @override
  State<OperationsDashboard> createState() => _OperationsDashboardState();
}

class _OperationsDashboardState extends State<OperationsDashboard> {
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
    final totalProducts = inventoryStore.products.length;
    final totalStock = inventoryStore.products.fold<int>(
      0,
      (sum, p) => sum + p.totalStock,
    );
    final lowStock = inventoryStore.products
        .where((p) => p.totalStock > 0 && p.totalStock <= p.reorderPoint)
        .length;
    final outOfStock = inventoryStore.products
        .where((p) => p.totalStock == 0)
        .length;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Easy Inventory',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Operations Dashboard',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Iconsax.box,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // KPI Cards
              Row(
                children: [
                  Expanded(
                    child: _buildKpiCard(
                      'Total Products',
                      '$totalProducts',
                      Iconsax.box,
                      AppColors.primaryGradient,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildKpiCard(
                      'Total Stock',
                      '$totalStock',
                      Iconsax.chart,
                      AppColors.greenGradient,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildKpiCard(
                      'Low Stock',
                      '$lowStock',
                      Iconsax.warning_2,
                      AppColors.orangeGradient,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildKpiCard(
                      'Out of Stock',
                      '$outOfStock',
                      Iconsax.danger,
                      AppColors.redGradient,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Quick Actions
              Text(
                'Quick Actions',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                childAspectRatio: 0.95,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                children: [
                  _buildActionCard(
                    context,
                    'Products',
                    Iconsax.box_1,
                    const Color(0xFF6366F1),
                    const ProductListScreen(),
                  ),
                  _buildActionCard(
                    context,
                    'Receipts',
                    Iconsax.document_download,
                    const Color(0xFF10B981),
                    const ReceiptListScreen(),
                  ),
                  _buildActionCard(
                    context,
                    'Deliveries',
                    Iconsax.truck_fast,
                    const Color(0xFFF59E0B),
                    const DeliveryListScreen(),
                  ),
                  _buildActionCard(
                    context,
                    'Transfers',
                    Iconsax.arrow_swap_horizontal,
                    const Color(0xFF8B5CF6),
                    const TransferListScreen(),
                  ),
                  _buildActionCard(
                    context,
                    'Adjustments',
                    Iconsax.edit_2,
                    const Color(0xFFEF4444),
                    const AdjustmentListScreen(),
                  ),
                  _buildActionCard(
                    context,
                    'Ledger',
                    Iconsax.document_text_1,
                    const Color(0xFF3B82F6),
                    const StockLedgerScreen(),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Recent Activity
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Activity',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StockLedgerScreen(),
                      ),
                    ),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...inventoryStore.operations
                  .take(3)
                  .map((op) => _buildRecentItem(op)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard(
    String title,
    String value,
    IconData icon,
    LinearGradient gradient,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.8), size: 22),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget screen,
  ) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 12,
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
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentItem(StockOperation op) {
    IconData icon;
    Color color;
    String subtitle;

    switch (op.type) {
      case OperationType.receipt:
        icon = Iconsax.document_download;
        color = AppColors.success;
        subtitle = 'From ${op.partner ?? "Unknown"}';
        break;
      case OperationType.delivery:
        icon = Iconsax.truck_fast;
        color = AppColors.warning;
        subtitle = 'To ${op.partner ?? "Walk-in"}';
        break;
      case OperationType.transfer:
        icon = Iconsax.arrow_swap_horizontal;
        color = const Color(0xFF8B5CF6);
        subtitle = '${op.sourceLocation} → ${op.destinationLocation}';
        break;
      case OperationType.adjustment:
        icon = Iconsax.edit_2;
        color = AppColors.error;
        subtitle = op.partner ?? 'Manual adjustment';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
                Text(
                  op.reference,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              op.status.name,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
      title: 'CoreInventory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        fontFamily: 'Inter',
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.signup: (context) => const SignupPage(),
        AppRoutes.shell: (context) => const AppShell(),
        AppRoutes.organizationManagement: (context) => const AppShell(),
        AppRoutes.adminDashboard: (context) => const AppShell(),
      },
    );
  }
}
