import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../core/constants/app_strings.dart';

class AuthState {
  final UserModel? user;
  final String? token;
  final bool isLoading;

  AuthState({this.user, this.token, this.isLoading = false});

  bool get isAuthenticated => token != null;
  bool get isAdmin => user?.role == 'admin';
  bool get isCashier => user?.role == 'cashier';
  bool get isStudent => user?.role == 'student';

  AuthState copyWith({UserModel? user, String? token, bool? isLoading}) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService();
  final _secureStorage = const FlutterSecureStorage();

  AuthNotifier() : super(AuthState()) {
    _loadStoredData();
  }

  Future<void> _loadStoredData() async {
    final token = await _secureStorage.read(key: AppStrings.tokenKey);
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(AppStrings.userDataKey);

    if (userData != null && token != null) {
      state = state.copyWith(
        token: token,
        user: UserModel.fromJson(jsonDecode(userData)),
      );
    }
  }

  Future<String?> login(String username, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _authService.login(username, password);
      if (response['success']) {
        final token = response['data']['token'];
        final user = UserModel.fromJson(response['data']['user']);

        await _secureStorage.write(key: AppStrings.tokenKey, value: token);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppStrings.userDataKey, jsonEncode(user.toJson()));

        state = state.copyWith(token: token, user: user, isLoading: false);
        return null;
      } else {
        state = state.copyWith(isLoading: false);
        return response['message'];
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: AppStrings.tokenKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppStrings.userDataKey);
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
