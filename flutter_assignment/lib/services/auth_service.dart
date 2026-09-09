import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = true;
  bool _isDarkMode = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;

  static const String _userKey = 'connect_call_user';
  static const String _darkModeKey = 'connect_call_dark_mode';

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    final userStr = prefs.getString(_userKey);
    if (userStr != null) {
      try {
        _currentUser = UserModel.fromJson(jsonDecode(userStr));
      } catch (e) {
        _currentUser = null;
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String emailOrPhone, String password) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Default mock user login
    final user = UserModel(
      id: 'user_me',
      name: emailOrPhone.contains('@') ? emailOrPhone.split('@')[0] : 'Alex Rivers',
      email: emailOrPhone.contains('@') ? emailOrPhone : 'alex.rivers@connectcall.io',
      phone: emailOrPhone.contains('@') ? '+1 (555) 019-2831' : emailOrPhone,
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
      isOnline: true,
    );

    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final user = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: '+1 (555) 234-5678',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400',
      isOnline: true,
    );

    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> updateProfile({required String name, String? avatarUrl}) async {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(
      name: name,
      avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));
    notifyListeners();
  }

  Future<void> toggleOnlineStatus() async {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(isOnline: !_currentUser!.isOnline);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, _isDarkMode);
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    notifyListeners();
  }
}
