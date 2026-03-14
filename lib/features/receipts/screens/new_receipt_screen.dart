import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models.dart';
import '../../../main.dart';
import '../../../core/theme/app_colors.dart';

class NewReceiptScreen extends StatefulWidget {
  const NewReceiptScreen({super.key});

  @override
  State<NewReceiptScreen> createState() => _NewReceiptScreenState();
}

class _NewReceiptScreenState extends State<NewReceiptScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _supplier;
  String _destination = 'Warehouse A';
  final List<Map<String, dynamic>> _items = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Receipt')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Supplier'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Iconsax.user),
                ),
                hint: const Text('Select supplier'),
                items: inventoryStore.suppliers
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _supplier = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              _sectionTitle('Destination'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _destination,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Iconsax.building),
                ),
                items: inventoryStore.warehouses
                    .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                    .toList(),
                onChanged: (v) => setState(() => _destination = v!),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionTitle('Products'),
                  OutlinedButton.icon(
                    onPressed: _showAddProductDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_items.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Iconsax.box_add,
                        size: 36,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No products added',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ..._items.asMap().entries.map(
                  (e) => _productTile(e.key, e.value),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
          ),
          onPressed: _validate,
          icon: const Icon(Iconsax.tick_circle),
          label: const Text('Validate & Receive'),
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(
    t,
    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
  );

  Widget _productTile(int index, Map<String, dynamic> item) {
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
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Iconsax.box, color: AppColors.success, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Qty: ${item['qty']}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Iconsax.trash, color: AppColors.error, size: 20),
            onPressed: () => setState(() => _items.removeAt(index)),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog() {
    String? selectedProductId;
    final qtyCtrl = TextEditingController(text: '1');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Product',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Product'),
              items: inventoryStore.products
                  .map(
                    (p) => DropdownMenuItem(value: p.id, child: Text(p.name)),
                  )
                  .toList(),
              onChanged: (v) => selectedProductId = v,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: qtyCtrl,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () {
                if (selectedProductId != null) {
                  final p = inventoryStore.getProduct(selectedProductId!);
                  setState(() {
                    _items.add({
                      'id': selectedProductId!,
                      'name': p?.name ?? '',
                      'qty': int.tryParse(qtyCtrl.text) ?? 1,
                    });
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _validate() {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add at least one product'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final itemsMap = <String, int>{};
    for (final item in _items) {
      itemsMap[item['id'] as String] =
          (itemsMap[item['id'] as String] ?? 0) + (item['qty'] as int);
    }

    inventoryStore.createReceipt(
      supplier: _supplier!,
      destination: _destination,
      items: itemsMap,
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Receipt created! Stock updated ✓'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
