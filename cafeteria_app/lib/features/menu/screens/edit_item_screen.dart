import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/menu_item_model.dart';
import '../../../providers/menu_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../core/constants/app_colors.dart';

class EditItemScreen extends ConsumerStatefulWidget {
  final MenuItemModel item;

  const EditItemScreen({super.key, required this.item});

  @override
  ConsumerState<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends ConsumerState<EditItemScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  late bool _isAvailable;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _descController = TextEditingController(text: widget.item.description);
    _priceController = TextEditingController(text: widget.item.price.toString());
    _categoryController = TextEditingController(text: widget.item.category);
    _isAvailable = true; // Defaulting to true for now
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Menu Item'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: AppColors.danger),
            onPressed: () => _confirmDelete(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildTextField(_nameController, 'Name'),
            const SizedBox(height: 16),
            _buildTextField(_descController, 'Description', maxLines: 3),
            const SizedBox(height: 16),
            _buildTextField(_priceController, 'Price', keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildTextField(_categoryController, 'Category'),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Is Available'),
              value: _isAvailable,
              activeThumbColor: AppColors.orange,
              onChanged: (val) => setState(() => _isAvailable = val),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Save Changes',
              onPressed: () async {
                final token = ref.read(authProvider).token;
                if (token == null) return;
                final updatedItem = MenuItemModel(
                  id: widget.item.id,
                  name: _nameController.text,
                  description: _descController.text,
                  price: double.tryParse(_priceController.text) ?? 0.0,
                  category: _categoryController.text,
                  imageUrl: widget.item.imageUrl,
                );

                final err = await ref
                    .read(menuProvider.notifier)
                    .updateMenuItem(updatedItem, token);
                if (!context.mounted) return;
                if (err == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item updated successfully')),
                  );
                  context.pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            child: Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
