import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/menu_provider.dart';
import '../widgets/menu_item_card.dart';
import '../../../shared/widgets/loading_spinner.dart';

class StudentMenuScreen extends StatefulWidget {
  const StudentMenuScreen({super.key});

  @override
  State<StudentMenuScreen> createState() => _StudentMenuScreenState();
}

class _StudentMenuScreenState extends State<StudentMenuScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<MenuProvider>(context, listen: false).fetchMenu());
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      body: menuProvider.isLoading
          ? const LoadingSpinner()
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: menuProvider.items.length,
              itemBuilder: (ctx, i) => MenuItemCard(item: menuProvider.items[i]),
            ),
    );
  }
}
