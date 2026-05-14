import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/menu_item_model.dart';
import '../services/menu_service.dart';

class MenuState {
  final List<MenuItemModel> items;
  final bool isLoading;
  final String? error;

  MenuState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  MenuState copyWith({
    List<MenuItemModel>? items,
    bool? isLoading,
    String? error,
  }) {
    return MenuState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MenuNotifier extends StateNotifier<MenuState> {
  final MenuService _menuService = MenuService();

  MenuNotifier() : super(MenuState()) {
    fetchMenu();
  }

  Future<void> fetchMenu() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _menuService.getMenu();
      if (response['success']) {
        final items = (response['data'] as List)
            .map((item) => MenuItemModel.fromJson(item))
            .toList();
        state = state.copyWith(items: items, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: response['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<String?> addMenuItem(MenuItemModel item, String token) async {
    try {
      final response = await _menuService.addItem(item, token);
      if (response['success']) {
        await fetchMenu();
        return null;
      }
      return response['message'];
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateMenuItem(MenuItemModel item, String token) async {
    try {
      final response = await _menuService.updateItem(item, token);
      if (response['success']) {
        await fetchMenu();
        return null;
      }
      return response['message'];
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteMenuItem(int id, String token) async {
    try {
      final response = await _menuService.deleteItem(id, token);
      if (response['success']) {
        await fetchMenu();
        return null;
      }
      return response['message'];
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> searchMenu(String query) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _menuService.searchMenu(query); 
      if (response['success']) {
        final items = (response['data'] as List)
            .map((item) => MenuItemModel.fromJson(item))
            .toList();
        state = state.copyWith(items: items, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final menuProvider = StateNotifierProvider<MenuNotifier, MenuState>((ref) {
  return MenuNotifier();
});
