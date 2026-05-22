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

    if (userData == null || token == null) return;

    // Don't restore an expired session. Otherwise the app would auto-route to a
    // logged-in screen with a dead token, and the first API call would fail with
    // "invalid token". Clearing it here sends the user to the landing page to
    // sign in again.
    if (_isTokenExpired(token)) {
      await _secureStorage.delete(key: AppStrings.tokenKey);
      await prefs.remove(AppStrings.userDataKey);
      return;
    }

    state = state.copyWith(
      token: token,
      user: UserModel.fromJson(jsonDecode(userData)),
    );
  }

  /// Returns true if the JWT's `exp` claim is in the past (or the token is
  /// malformed / has no expiry). This is a local convenience check only — the
  /// server still validates the token on every request.
  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      // JWTs use base64url without padding; normalize before decoding.
      var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      payload = payload.padRight((payload.length + 3) ~/ 4 * 4, '=');
      final claims = jsonDecode(utf8.decode(base64.decode(payload))) as Map<String, dynamic>;
      final exp = claims['exp'];
      if (exp is! int) return true;
      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return !DateTime.now().isBefore(expiry);
    } catch (_) {
      return true;
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

  /// Uploads a new profile picture, then updates the in-memory user and the
  /// persisted copy so the avatar survives app restarts. Returns null on
  /// success, or an error message string on failure.
  Future<String?> updateAvatar(String filePath) async {
    final token = state.token;
    final user = state.user;
    if (token == null || user == null) return 'Not signed in';

    final response = await _authService.uploadAvatar(token, filePath);
    if (response['success'] != true) {
      return response['message'] ?? 'Failed to upload picture';
    }

    final updatedUser = UserModel.fromJson(response['data']);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppStrings.userDataKey, jsonEncode(updatedUser.toJson()));

    state = state.copyWith(user: updatedUser);
    return null;
  }

  /// Updates editable profile fields (registration number, year of study),
  /// then refreshes the in-memory + persisted user from the server's response.
  /// Returns null on success, or an error message on failure.
  Future<String?> updateProfile({
    String? registrationNumber,
    int? yearOfStudy,
  }) async {
    final token = state.token;
    if (token == null) return 'Not signed in';

    final response = await _authService.updateProfile(
      token,
      registrationNumber: registrationNumber,
      yearOfStudy: yearOfStudy,
    );
    if (response['success'] != true) {
      return response['message'] ?? 'Failed to save profile';
    }

    final updatedUser = UserModel.fromJson(response['data']);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppStrings.userDataKey, jsonEncode(updatedUser.toJson()));

    state = state.copyWith(user: updatedUser);
    return null;
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
