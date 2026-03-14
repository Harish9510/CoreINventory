import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../models.dart';
import '../../../../core/theme/app_colors.dart';

class NewAdjustmentScreen extends StatefulWidget {
  const NewAdjustmentScreen({super.key});

  @override
  State<NewAdjustmentScreen> createState() => _NewAdjustmentScreenState();
}

class _NewAdjustmentScreenState extends State<NewAdjustmentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Adjustment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField(
              decoration: const InputDecoration(labelText: 'Select Product'),
              items: DummyData.products
                  .map(
                    (p) => DropdownMenuItem(value: p.id, child: Text(p.name)),
                  )
                  .toList(),
              onChanged: (v) {},
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Physical Quantitiy Counted',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Reason for Adjustment',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply Adjustment'),
            ),
          ],
        ),
      ),
    );
  }
}
