import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Basic Information'),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  hintText: 'e.g. Ergonomic Office Chair',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'SKU / Product Code',
                  hintText: 'e.g. CH-ERGO-01',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: const [
                        DropdownMenuItem(
                          value: 'Raw Materials',
                          child: Text('Raw Materials'),
                        ),
                        DropdownMenuItem(
                          value: 'Furniture',
                          child: Text('Furniture'),
                        ),
                        DropdownMenuItem(
                          value: 'Electronics',
                          child: Text('Electronics'),
                        ),
                      ],
                      onChanged: (value) {},
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Unit of Measure',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Pieces',
                          child: Text('Pieces'),
                        ),
                        DropdownMenuItem(value: 'Units', child: Text('Units')),
                        DropdownMenuItem(value: 'Kg', child: Text('Kg')),
                      ],
                      onChanged: (value) {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Initial Setup'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Initial Stock Count',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Reorder Point',
                        hintText: 'Alert when stock drops below',
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context); // Simulate creation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product created successfully')),
              );
            }
          },
          child: const Text('Save Product'),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
    );
  }
}
