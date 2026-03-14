import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../models.dart';
import '../../../../core/theme/app_colors.dart';

class NewReceiptScreen extends StatefulWidget {
  const NewReceiptScreen({super.key});

  @override
  State<NewReceiptScreen> createState() => _NewReceiptScreenState();
}

class _NewReceiptScreenState extends State<NewReceiptScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedSupplier;
  final List<Map<String, dynamic>> _selectedProducts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Receipt')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Supplier Details'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Supplier',
                  prefixIcon: Icon(Iconsax.user),
                ),
                items: DummyData.suppliers.map((s) {
                  return DropdownMenuItem(value: s.name, child: Text(s.name));
                }).toList(),
                onChanged: (value) => setState(() => _selectedSupplier = value),
                validator: (value) =>
                    value == null ? 'Please select a supplier' : null,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('Products'),
                  TextButton.icon(
                    onPressed: _addProduct,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Product'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_selectedProducts.isEmpty)
                _buildEmptyProducts()
              else
                ..._selectedProducts.map((p) => _buildProductItem(p)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomAction(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
    );
  }

  Widget _buildEmptyProducts() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, style: BorderStyle.none),
      ),
      child: const Column(
        children: [
          Icon(Iconsax.box_add, color: AppColors.textSecondary),
          SizedBox(height: 8),
          Text(
            'No products added yet',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Qty: ${item['quantity']}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Iconsax.trash, color: AppColors.error, size: 20),
            onPressed: () => setState(() => _selectedProducts.remove(item)),
          ),
        ],
      ),
    );
  }

  void _addProduct() {
    // For demo purposes, we just add the first product from dummy data
    setState(() {
      _selectedProducts.add({
        'id': DummyData.products.first.id,
        'name': DummyData.products.first.name,
        'quantity': 10,
      });
    });
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: () {
          if (_formKey.currentState!.validate() &&
              _selectedProducts.isNotEmpty) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Receipt created and stock updated'),
              ),
            );
          } else if (_selectedProducts.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please add at least one product')),
            );
          }
        },
        child: const Text('Validate & Receive'),
      ),
    );
  }
}
