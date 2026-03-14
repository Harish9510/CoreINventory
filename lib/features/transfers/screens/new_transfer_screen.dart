import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../models.dart';
import '../../../../core/theme/app_colors.dart';

class NewTransferScreen extends StatefulWidget {
  const NewTransferScreen({super.key});

  @override
  State<NewTransferScreen> createState() => _NewTransferScreenState();
}

class _NewTransferScreenState extends State<NewTransferScreen> {
  String? _sourceLoc;
  String? _destLoc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Internal Transfer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Source Location'),
              items: const [
                DropdownMenuItem(
                  value: 'Warehouse A',
                  child: Text('Warehouse A'),
                ),
              ],
              onChanged: (v) => _sourceLoc = v,
            ),
            const SizedBox(height: 16),
            const Icon(Iconsax.arrow_down),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Destination Location',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Warehouse B',
                  child: Text('Warehouse B'),
                ),
              ],
              onChanged: (v) => _destLoc = v,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Confirm Transfer'),
            ),
          ],
        ),
      ),
    );
  }
}
