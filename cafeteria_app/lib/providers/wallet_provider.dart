import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/wallet_service.dart';
import 'auth_provider.dart';

class WalletState {
  final double balance;
  final List<Map<String, dynamic>> transactions;
  final bool isLoading;
  final String? error;

  const WalletState({
    this.balance = 0.0,
    this.transactions = const [],
    this.isLoading = false,
    this.error,
  });

  WalletState copyWith({
    double? balance,
    List<Map<String, dynamic>>? transactions,
    bool? isLoading,
    String? error,
  }) {
    return WalletState(
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class WalletNotifier extends StateNotifier<WalletState> {
  final WalletService _service = WalletService();
  final Ref _ref;

  WalletNotifier(this._ref) : super(const WalletState());

  String? _token() => _ref.read(authProvider).token;

  Future<void> fetchBalance() async {
    final token = _token();
    if (token == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final res = await _service.getBalance(token);
      if (res['success'] == true) {
        final bal = res['balance'];
        state = state.copyWith(
          balance: bal is String ? double.parse(bal) : (bal as num).toDouble(),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, error: res['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchTransactions() async {
    final token = _token();
    if (token == null) return;
    try {
      final res = await _service.getTransactions(token);
      if (res['success'] == true) {
        state = state.copyWith(
          transactions: List<Map<String, dynamic>>.from(res['data']),
        );
      }
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> topUp(double amount, String paymentMethod) async {
    final token = _token();
    if (token == null) return null;
    try {
      final res = await _service.topUp(amount, paymentMethod, token);
      if (res['success'] == true) {
        final data = res['data'] as Map<String, dynamic>;
        final bal = data['new_balance'];
        state = state.copyWith(
          balance: bal is String ? double.parse(bal) : (bal as num).toDouble(),
        );
        await fetchTransactions();
        return data;
      }
      state = state.copyWith(error: res['message']);
      return null;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }
}

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return WalletNotifier(ref);
});
