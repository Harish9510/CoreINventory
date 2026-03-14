import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../models.dart';
import '../../../../core/theme/app_colors.dart';
import 'new_adjustment_screen.dart';

class AdjustmentListScreen extends StatelessWidget {
  const AdjustmentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stock Adjustments')),
      body: const Center(child: Text('No adjustments recorded')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NewAdjustmentScreen()),
        ),
        label: const Text(
          'New Adjustment',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Iconsax.edit, color: Colors.white),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
