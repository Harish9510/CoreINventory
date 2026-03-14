import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models.dart';
import '../../../main.dart';
import '../../../core/theme/app_colors.dart';

class NewAdjustmentScreen extends StatefulWidget {
  const NewAdjustmentScreen({super.key});

  @override
  State<NewAdjustmentScreen> createState() => _NewAdjustmentScreenState();
}

class _NewAdjustmentScreenState extends State<NewAdjustmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qtyCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  String? _selectedProductId;
  String? _selectedLocation;

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = _selectedProductId != null
        ? inventoryStore.getProduct(_selectedProductId!)
        : null;
    final currentStock = product != null && _selectedLocation != null
        ? product.stockPerLocation[_selectedLocation] ?? 0
        : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Adjustment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Select Product'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Iconsax.box),
                ),
                hint: const Text('Choose product'),
                items: inventoryStore.products
                    .map(
                      (p) => DropdownMenuItem(value: p.id, child: Text(p.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() {
                  _selectedProductId = v;
                  _selectedLocation = null;
                }),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              _sectionTitle('Location'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Iconsax.building),
                ),
                hint: const Text('Choose location'),
                items:
                    (product?.stockPerLocation.keys.toList() ??
                            inventoryStore.warehouses)
                        .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                        .toList(),
                onChanged: (v) => setState(() => _selectedLocation = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              if (_selectedLocation != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.infoLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Iconsax.info_circle,
                          color: AppColors.info,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Current system stock: $currentStock ${product?.unitOfMeasure ?? ""}',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              _sectionTitle('Physical Count'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _qtyCtrl,
                decoration: const InputDecoration(
                  labelText: 'Counted Quantity',
                  prefixIcon: Icon(Iconsax.calculator),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _reasonCtrl,
                decoration: const InputDecoration(
                  labelText: 'Reason for Adjustment',
                  prefixIcon: Icon(Iconsax.note),
                ),
                maxLines: 2,
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
          onPressed: _apply,
          icon: const Icon(Iconsax.tick_circle),
          label: const Text('Apply Adjustment'),
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(
    t,
    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
  );

  void _apply() {
    if (!_formKey.currentState!.validate()) return;
    final newQty = int.tryParse(_qtyCtrl.text) ?? 0;
    inventoryStore.createAdjustment(
      productId: _selectedProductId!,
      location: _selectedLocation!,
      newQuantity: newQty,
      reason: _reasonCtrl.text.isNotEmpty
          ? _reasonCtrl.text
          : 'Manual count correction',
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Adjustment applied! Stock corrected ✓'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
