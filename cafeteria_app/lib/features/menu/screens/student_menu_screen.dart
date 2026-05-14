import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/menu_provider.dart';
import '../../../providers/cart_provider.dart';
import '../widgets/menu_item_card.dart';
import '../../../shared/widgets/loading_spinner.dart';
import '../../../core/constants/app_colors.dart';

class StudentMenuScreen extends ConsumerStatefulWidget {
  const StudentMenuScreen({super.key});

  @override
  ConsumerState<StudentMenuScreen> createState() => _StudentMenuScreenState();
}

class _StudentMenuScreenState extends ConsumerState<StudentMenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(menuProvider.notifier).searchMenu(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuState = ref.watch(menuProvider);
    final cartCount = ref.watch(cartProvider).itemList.fold<int>(0, (s, it) => s + it.quantity);

    final filtered = _selectedCategory == 'All'
        ? menuState.items
        : menuState.items
            .where((i) => i.category.toLowerCase() == _selectedCategory.toLowerCase())
            .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header (navy)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              decoration: BoxDecoration(color: AppColors.navyBlue),
              child: Row(
                children: [
                  const SizedBox(width: 48), // balance the cart icon on the right
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Cafeteria menu',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                        onPressed: () => context.push('/cart'),
                      ),
                      if (cartCount > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.orange,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                            alignment: Alignment.center,
                            child: Text(
                              '$cartCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                  filled: true,
                  fillColor: AppColors.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Category chips
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _CategoryChip(
                    label: 'All',
                    selected: _selectedCategory == 'All',
                    onTap: () => setState(() => _selectedCategory = 'All'),
                  ),
                  const SizedBox(width: 10),
                  _CategoryChip(
                    label: 'Meals',
                    selected: _selectedCategory == 'Meals',
                    onTap: () => setState(() => _selectedCategory = 'Meals'),
                  ),
                  const SizedBox(width: 10),
                  _CategoryChip(
                    label: 'Drinks',
                    selected: _selectedCategory == 'Drinks',
                    onTap: () => setState(() => _selectedCategory = 'Drinks'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Grid
            Expanded(
              child: menuState.isLoading
                  ? const LoadingSpinner()
                  : filtered.isEmpty
                      ? _empty()
                      : RefreshIndicator(
                          onRefresh: () => ref.read(menuProvider.notifier).fetchMenu(),
                          child: GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.78,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (ctx, i) => MenuItemCard(item: filtered[i]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No menu items found',
            style: TextStyle(color: AppColors.textLight, fontSize: 16),
          ),
          TextButton(
            onPressed: () {
              _searchController.clear();
              ref.read(menuProvider.notifier).fetchMenu();
            },
            child: Text('Show all items', style: TextStyle(color: AppColors.orange)),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.orange : AppColors.inputFill,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textDark,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
