import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../core/constants/app_strings.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  String? _token;
  bool _isLoading = false;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  bool get isAdmin => _user?.role == 'admin';

  AuthProvider() {
    _loadStoredData();
  }

  Future<void> _loadStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppStrings.tokenKey);
    final userData = prefs.getString(AppStrings.userDataKey);
    if (userData != null) {
      _user = UserModel.fromJson(jsonDecode(userData));
    }
    notifyListeners();
  }

  Future<String?> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _authService.login(username, password);
      if (response['success']) {
        _token = response['data']['token'];
        _user = UserModel.fromJson(response['data']['user']);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppStrings.tokenKey, _token!);
        await prefs.setString(AppStrings.userDataKey, jsonEncode(_user!.toJson()));
        
        _isLoading = false;
        notifyListeners();
        return null; // Success
      } else {
        _isLoading = false;
        notifyListeners();
        return response['message'];
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppStrings.tokenKey);
    await prefs.remove(AppStrings.userDataKey);
    notifyListeners();
  }
}
