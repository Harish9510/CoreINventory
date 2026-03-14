import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../models.dart';
import '../../../../core/theme/app_colors.dart';

class NewDeliveryScreen extends StatefulWidget {
  const NewDeliveryScreen({super.key});

  @override
  State<NewDeliveryScreen> createState() => _NewDeliveryScreenState();
}

class _NewDeliveryScreenState extends State<NewDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> _selectedProducts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Delivery Order')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Customer Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'e.g. Acme Corp / Walk-in',
                  prefixIcon: Icon(Iconsax.user),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Products to Ship',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _addProduct,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Product'),
                  ),
                ],
              ),
              ..._selectedProducts.map(
                (p) => ListTile(
                  title: Text(p['name']),
                  subtitle: Text('Qty: ${p['quantity']}'),
                  trailing: IconButton(
                    icon: const Icon(Iconsax.trash),
                    onPressed: () =>
                        setState(() => _selectedProducts.remove(p)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
          onPressed: () {
            if (_selectedProducts.isNotEmpty) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Delivery Validated')),
              );
            }
          },
          child: const Text('Validate & Ship'),
        ),
      ),
    );
  }

  void _addProduct() {
    setState(() {
      _selectedProducts.add({'name': 'Steel Rods 10mm', 'quantity': 5});
    });
  }
}
