import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/offline_mode_service.dart';
import '../models/models.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final OfflineModeService _offlineService = OfflineModeService();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOfflineMode = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isStudent => _currentUser?.role == 'student';
  bool get isTeacher => _currentUser?.role == 'teacher';
  bool get isOfflineMode => _isOfflineMode;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Check if user is already logged in
  Future<void> checkAuthStatus() async {
    final token = await _apiService.getToken();
    if (token != null) {
      if (token.startsWith('offline_token_')) {
        _isOfflineMode = true;
        await _loadOfflineUserProfile();
      } else {
        await loadUserProfile();
      }
    }
  }

  // Load user profile from API
  Future<bool> loadUserProfile() async {
    try {
      _setLoading(true);
      _setError(null);

      // For now, just create a user from stored data
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('current_user');

      if (userData != null) {
        _currentUser = User.fromJson(jsonDecode(userData));
        _isOfflineMode = false;
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      _setError('Error loading data: $e');
      await _loadOfflineUserProfile();
      return _currentUser != null;
    } finally {
      _setLoading(false);
    }
  }

  // Load user profile from offline storage
  Future<void> _loadOfflineUserProfile() async {
    try {
      final result = await _offlineService.getCurrentUser();
      if (result['success']) {
        _currentUser = User.fromJson(result['data']);
        _isOfflineMode = true;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading offline profile: $e');
    }
  }

  // Login with fallback to offline mode
  Future<bool> login(String email, String password, String userType) async {
    try {
      _setLoading(true);
      _setError(null);

      // Try online login first
      try {
        Map<String, dynamic> result;

        if (userType == 'student') {
          result = await _apiService.loginStudent(email, password);
        } else {
          result = await _apiService.loginTeacher(email, password);
        }

        if (result['success']) {
          // Create user from login response
          final userData = result['data'];
          _currentUser = User(
            id: userData['user']?['id']?.toString() ?? '',
            name: userData['user']?['name'] ?? email.split('@')[0],
            email: email,
            role: userType,
          );

          // Save user data
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('current_user', jsonEncode(_currentUser!.toJson()));

          _isOfflineMode = false;
          notifyListeners();
          return true;
        } else {
          _setError(result['message']);
        }
      } catch (e) {
        // If online login fails, try offline mode
        print('Online login failed, trying offline mode: $e');

        final offlineResult = await _offlineService.login(email, password, userType);

        if (offlineResult['success']) {
          _currentUser = User.fromJson(offlineResult['data']['user']);
          _isOfflineMode = true;
          notifyListeners();
          return true;
        } else {
          _setError(offlineResult['message']);
        }
      }

      return false;
    } catch (e) {
      _setError('Login error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register Student
  Future<bool> registerStudent({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final studentData = {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };

      // Try online registration first
      try {
        final result = await _apiService.registerStudent(studentData);

        if (result['success']) {
          _isOfflineMode = false;
          return true;
        } else {
          _setError(result['message']);
        }
      } catch (e) {
        // If online registration fails, try offline mode
        print('Online registration failed, trying offline mode: $e');

        final offlineData = {
          ...studentData,
          'role': 'student',
        };

        final offlineResult = await _offlineService.register(offlineData);

        if (offlineResult['success']) {
          _isOfflineMode = true;
          _setError('Account created in offline mode');
          return true;
        } else {
          _setError(offlineResult['message']);
        }
      }

      return false;
    } catch (e) {
      _setError('Registration error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register Teacher
  Future<bool> registerTeacher({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final teacherData = {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };

      // Try online registration first
      try {
        final result = await _apiService.registerTeacher(teacherData);

        if (result['success']) {
          _isOfflineMode = false;
          return true;
        } else {
          _setError(result['message']);
        }
      } catch (e) {
        // If online registration fails, try offline mode
        print('Online registration failed, trying offline mode: $e');

        final offlineData = {
          ...teacherData,
          'role': 'teacher',
        };

        final offlineResult = await _offlineService.register(offlineData);

        if (offlineResult['success']) {
          _isOfflineMode = true;
          _setError('Account created in offline mode');
          return true;
        } else {
          _setError(offlineResult['message']);
        }
      }

      return false;
    } catch (e) {
      _setError('Registration error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _setLoading(true);

      if (_isOfflineMode) {
        await _offlineService.logout();
      } else {
        await _apiService.logout();
      }

      _currentUser = null;
      _isOfflineMode = false;

      // Clear stored user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user');

      notifyListeners();
    } catch (e) {
      // Even if logout fails on server, clear local data
      _currentUser = null;
      _isOfflineMode = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user');

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Clear error
  void clearError() {
    _setError(null);
  }
}