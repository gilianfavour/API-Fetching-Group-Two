import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoggedIn = false;
  String? _token;
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  // =========================================
  // GETTERS
  // =========================================
  bool get isLoggedIn => _isLoggedIn;
  String? get token => _token;
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // =========================================
  // INITIALIZE AUTH FROM LOCAL STORAGE
  // =========================================
  Future<void> loadPersistedAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('auth_token');
      final savedUserJson = prefs.getString('auth_user');

      if (savedToken != null && savedToken.isNotEmpty) {
        _token = savedToken;
        _isLoggedIn = true;
        if (savedUserJson != null) {
          _user = UserModel.fromJson(jsonDecode(savedUserJson));
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading persisted auth: $e');
    }
  }

  // =========================================
  // REGISTER
  // =========================================
  Future<bool> register({
    required String name,
    required String emailOrContact,
    required String password,
    required String passwordConfirmation,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.register(
        name: name,
        emailOrContact: emailOrContact,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // =========================================
  // LOGIN
  // =========================================
  Future<bool> login({
    required String emailOrContact,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        emailOrContact: emailOrContact,
        password: password,
      );

      // Handle token formats: e.g. token, access_token, data.token
      final extractedToken = response['token'] ??
          response['access_token'] ??
          response['data']?['token'] ??
          response['data']?['access_token'];

      if (extractedToken == null) {
        throw Exception('Token not found in response');
      }

      _token = extractedToken.toString();
      _isLoggedIn = true;

      // Extract user info if available
      final rawUser = response['user'] ?? response['data']?['user'] ?? {
        'id': 1,
        'name': emailOrContact.split('@')[0],
        'email': emailOrContact.contains('@') ? emailOrContact : null,
        'contact': emailOrContact.contains('@') ? null : emailOrContact,
      };

      _user = UserModel.fromJson(rawUser);

      // Persist to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('auth_user', jsonEncode(_user!.toJson()));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // =========================================
  // LOGOUT
  // =========================================
  Future<void> logout() async {
    _token = null;
    _user = null;
    _isLoggedIn = false;
    _error = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user');

    notifyListeners();
  }
}
