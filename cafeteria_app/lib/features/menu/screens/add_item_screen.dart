import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/menu_item_model.dart';
import '../../../providers/menu_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../core/constants/app_colors.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  const AddItemScreen({super.key});

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Menu Item'),
        backgroundColor: AppColors.navyBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _nameController, 
              decoration: const InputDecoration(labelText: 'Item Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController, 
              decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController, 
              decoration: const InputDecoration(labelText: 'Price', prefixText: '\$', border: OutlineInputBorder()), 
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _categoryController, 
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: 'Add Item',
              isLoading: _isLoading,
              onPressed: () async {
                if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill name and price')));
                   return;
                }

                setState(() => _isLoading = true);
                final authState = ref.read(authProvider);
                final item = MenuItemModel(
                  id: 0,
                  name: _nameController.text,
                  description: _descController.text,
                  price: double.tryParse(_priceController.text) ?? 0.0,
                  category: _categoryController.text,
                );
                
                final error = await ref.read(menuProvider.notifier).addMenuItem(item, authState.token!);
                setState(() => _isLoading = false);
                
                if (error == null) {
                   if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item added successfully')));
                     context.pop();
                   }
                } else {
                   if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                   }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
