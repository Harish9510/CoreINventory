import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models.dart';
import '../../../main.dart';
import '../../../theme/app_colors.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: '0');
  final _reorderCtrl = TextEditingController(text: '0');
  String _category = 'Raw Materials';
  String _uom = 'Pieces';
  String _location = 'Main Store';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _skuCtrl.dispose();
    _stockCtrl.dispose();
    _reorderCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Basic Information'),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  prefixIcon: Icon(Iconsax.box),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _skuCtrl,
                decoration: const InputDecoration(
                  labelText: 'SKU / Product Code',
                  prefixIcon: Icon(Iconsax.barcode),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _category,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Iconsax.category),
                ),
                items: inventoryStore.categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _uom,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Unit of Measure',
                  prefixIcon: Icon(Iconsax.ruler),
                ),
                items: ['Pieces', 'Units', 'Kg', 'Reams']
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (v) => setState(() => _uom = v!),
              ),
              const SizedBox(height: 28),
              _sectionTitle('Stock Setup'),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _location,
                decoration: const InputDecoration(
                  labelText: 'Initial Location',
                  prefixIcon: Icon(Iconsax.location),
                ),
                items: inventoryStore.warehouses
                    .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                    .toList(),
                onChanged: (v) => setState(() => _location = v!),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Initial Stock',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextFormField(
                      controller: _reorderCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Reorder Point',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
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
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
          ),
          onPressed: _saveProduct,
          child: const Text('Save Product'),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) return;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final stock = int.tryParse(_stockCtrl.text) ?? 0;
    final reorder = int.tryParse(_reorderCtrl.text) ?? 0;

    inventoryStore.addProduct(
      Product(
        id: id,
        name: _nameCtrl.text,
        sku: _skuCtrl.text,
        category: _category,
        unitOfMeasure: _uom,
        reorderPoint: reorder,
        stockPerLocation: {_location: stock},
      ),
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_nameCtrl.text} added successfully!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
