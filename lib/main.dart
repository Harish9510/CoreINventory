import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'features/products/screens/product_list_screen.dart';
import 'features/receipts/screens/receipt_list_screen.dart';
import 'features/deliveries/screens/delivery_list_screen.dart';
import 'features/transfers/screens/transfer_list_screen.dart';
import 'features/adjustments/screens/adjustment_list_screen.dart';
import 'features/ledger/screens/stock_ledger_screen.dart';

void main() {
  runApp(const EasyInventoryApp());
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

class OperationsDashboard extends StatelessWidget {
  const OperationsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Operations')),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildOpCard(
            context,
            'Products',
            Iconsax.box,
            Colors.blue,
            const ProductListScreen(),
          ),
          _buildOpCard(
            context,
            'Receipts',
            Iconsax.document_download,
            Colors.green,
            const ReceiptListScreen(),
          ),
          _buildOpCard(
            context,
            'Deliveries',
            Iconsax.document_upload,
            Colors.orange,
            const DeliveryListScreen(),
          ),
          _buildOpCard(
            context,
            'Transfers',
            Iconsax.shuffle,
            Colors.purple,
            const TransferListScreen(),
          ),
          _buildOpCard(
            context,
            'Adjustments',
            Iconsax.edit,
            Colors.red,
            const AdjustmentListScreen(),
          ),
          _buildOpCard(
            context,
            'Stock Ledger',
            Iconsax.document_text,
            Colors.grey,
            const StockLedgerScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildOpCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget screen,
  ) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
