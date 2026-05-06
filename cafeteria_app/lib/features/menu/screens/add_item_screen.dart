import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../models/menu_item_model.dart';
import '../../../providers/menu_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/custom_button.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Menu Item')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Description')),
            TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
            TextField(controller: _categoryController, decoration: const InputDecoration(labelText: 'Category')),
            const SizedBox(height: 30),
            CustomButton(
              text: 'Add Item',
              onPressed: () async {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final item = MenuItemModel(
                  id: 0,
                  name: _nameController.text,
                  description: _descController.text,
                  price: double.parse(_priceController.text),
                  category: _categoryController.text,
                );
                final error = await Provider.of<MenuProvider>(context, listen: false).addMenuItem(item, auth.token!);
                if (error == null) context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
