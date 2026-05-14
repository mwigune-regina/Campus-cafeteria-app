import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/order_service.dart';
import 'auth_provider.dart';

class OrderListState {
  final List<Map<String, dynamic>> orders;
  final bool isLoading;
  final String? error;

  const OrderListState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
  });

  OrderListState copyWith({
    List<Map<String, dynamic>>? orders,
    bool? isLoading,
    String? error,
  }) {
    return OrderListState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MyOrdersNotifier extends StateNotifier<OrderListState> {
  final OrderService _service = OrderService();
  final Ref _ref;

  MyOrdersNotifier(this._ref) : super(const OrderListState());

  Future<void> fetch() async {
    final token = _ref.read(authProvider).token;
    if (token == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final res = await _service.getMyOrders(token);
      if (res['success'] == true) {
        state = state.copyWith(
          orders: List<Map<String, dynamic>>.from(res['data']),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, error: res['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

class CashierQueueNotifier extends StateNotifier<OrderListState> {
  final OrderService _service = OrderService();
  final Ref _ref;

  CashierQueueNotifier(this._ref) : super(const OrderListState());

  Future<void> fetch() async {
    final token = _ref.read(authProvider).token;
    if (token == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final res = await _service.getQueue(token);
      if (res['success'] == true) {
        state = state.copyWith(
          orders: List<Map<String, dynamic>>.from(res['data']),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, error: res['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> updateStatus(int id, String status) async {
    final token = _ref.read(authProvider).token;
    if (token == null) return false;
    try {
      final res = await _service.updateStatus(id, status, token);
      if (res['success'] == true) {
        await fetch();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}

class CashierHistoryNotifier extends StateNotifier<OrderListState> {
  final OrderService _service = OrderService();
  final Ref _ref;

  CashierHistoryNotifier(this._ref) : super(const OrderListState());

  Future<void> fetch({String? statusFilter}) async {
    final token = _ref.read(authProvider).token;
    if (token == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final res = await _service.getAllOrders(token, status: statusFilter);
      if (res['success'] == true) {
        state = state.copyWith(
          orders: List<Map<String, dynamic>>.from(res['data']),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, error: res['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final myOrdersProvider = StateNotifierProvider<MyOrdersNotifier, OrderListState>((ref) {
  return MyOrdersNotifier(ref);
});

final cashierQueueProvider = StateNotifierProvider<CashierQueueNotifier, OrderListState>((ref) {
  return CashierQueueNotifier(ref);
});

final cashierHistoryProvider = StateNotifierProvider<CashierHistoryNotifier, OrderListState>((ref) {
  return CashierHistoryNotifier(ref);
});
