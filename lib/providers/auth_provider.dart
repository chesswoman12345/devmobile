import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.role == 'admin';

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      final token = response.data['access_token'];
      final userJson = response.data['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      _user = User.fromJson(userJson);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password, String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.dio.post('/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });

      final token = response.data['access_token'];
      final userJson = response.data['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      _user = User.fromJson(userJson);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.dio.post('/logout');
    } catch (e) {
      // ignore
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _user = null;
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) return;

    try {
      final response = await _apiService.dio.get('/user');
      _user = User.fromJson(response.data);
      notifyListeners();
    } catch (e) {
      // Token might be invalid
      await prefs.remove('token');
    }
  }
}
