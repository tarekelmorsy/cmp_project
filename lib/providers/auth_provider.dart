// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../services/api_service.dart';
// import '../models/models.dart';
//
// class AuthProvider with ChangeNotifier {
//   final ApiService _apiService = ApiService();
//
//   User? _currentUser;
//   bool _isLoading = false;
//   String? _errorMessage;
//
//   User? get currentUser => _currentUser;
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;
//   bool get isLoggedIn => _currentUser != null;
//   bool get isStudent => _currentUser?.role == 'student';
//   bool get isTeacher => _currentUser?.role == 'teacher';
//
//   void _setLoading(bool loading) {
//     _isLoading = loading;
//     notifyListeners();
//   }
//
//   void _setError(String? error) {
//     _errorMessage = error;
//     notifyListeners();
//   }
//
//   // Check if user is already logged in
//   Future<void> checkAuthStatus() async {
//     final token = await _apiService.getToken();
//     if (token != null) {
//       await loadUserProfile();
//     }
//   }
//
//   // Load user profile
//   Future<bool> loadUserProfile() async {
//     try {
//       _setLoading(true);
//       _setError(null);
//
//       final result = await _apiService.getUserProfile();
//
//       if (result['success']) {
//         _currentUser = User.fromJson(result['data']);
//         notifyListeners();
//         return true;
//       } else {
//         _setError(result['message']);
//         await logout();
//         return false;
//       }
//     } catch (e) {
//       _setError('خطأ في تحميل البيانات: $e');
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }
//
//   // Login
//   Future<bool> login(String email, String password) async {
//     try {
//       _setLoading(true);
//       _setError(null);
//
//       final result = await _apiService.login(email, password);
//
//       if (result['success']) {
//         _currentUser = User.fromJson(result['data']['user']);
//         notifyListeners();
//         return true;
//       } else {
//         _setError(result['message']);
//         return false;
//       }
//     } catch (e) {
//       _setError('خطأ في تسجيل الدخول: $e');
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }
//
//   // Register Student
//   Future<bool> registerStudent({
//     required String name,
//     required String email,
//     required String password,
//     required String studentId,
//     required String phone,
//     required String department,
//   }) async {
//     try {
//       _setLoading(true);
//       _setError(null);
//
//       final studentData = {
//         'name': name,
//         'email': email,
//         'password': password,
//         'password_confirmation': studentId,
//         // 'phone': phone,
//         // 'department': department,
//       };
//
//       final result = await _apiService.registerStudent(studentData);
//
//       if (result['success']) {
//         return true;
//       } else {
//         _setError(result['message']);
//         return false;
//       }
//     } catch (e) {
//       _setError('خطأ في التسجيل: $e');
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }
//
//   // Register Teacher
//   Future<bool> registerTeacher({
//     required String name,
//     required String email,
//     required String password,
//     required String teacherId,
//     required String phone,
//     required String department,
//   }) async {
//     try {
//       _setLoading(true);
//       _setError(null);
//
//       final teacherData = {
//         'name': name,
//         'email': email,
//         'password': password,
//         'teacher_id': teacherId,
//         'phone': phone,
//         'department': department,
//       };
//
//       final result = await _apiService.registerTeacher(teacherData);
//
//       if (result['success']) {
//         return true;
//       } else {
//         _setError(result['message']);
//         return false;
//       }
//     } catch (e) {
//       _setError('خطأ في التسجيل: $e');
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }
//
//   // Logout
//   Future<void> logout() async {
//     try {
//       _setLoading(true);
//       await _apiService.logout();
//       _currentUser = null;
//       notifyListeners();
//     } catch (e) {
//       // Even if logout fails on server, clear local data
//       _currentUser = null;
//       notifyListeners();
//     } finally {
//       _setLoading(false);
//     }
//   }
//
//   // Clear error
//   void clearError() {
//     _setError(null);
//   }
// }
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

      final result = await _apiService.getUserProfile();

      if (result['success']) {
        _currentUser = User.fromJson(result['data']);
        _isOfflineMode = false;
        notifyListeners();
        return true;
      } else {
        _setError(result['message']);
        // Try offline mode as fallback
        await _loadOfflineUserProfile();
        return _currentUser != null;
      }
    } catch (e) {
      _setError('خطأ في تحميل البيانات: $e');
      // Try offline mode as fallback
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
  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      // Try online login first
      try {
        final result = await _apiService.login(email, password);

        if (result['success']) {
          _currentUser = User.fromJson(result['data']['user']);
          _isOfflineMode = false;
          notifyListeners();
          return true;
        } else {
          _setError(result['message']);
        }
      } catch (e) {
        // If online login fails, try offline mode
        print('Online login failed, trying offline mode: $e');

        final offlineResult = await _offlineService.login(email, password);

        if (offlineResult['success']) {
          _currentUser = User.fromJson(offlineResult['data']['user']);
          _isOfflineMode = true;
          notifyListeners();

          // Show offline mode indicator
          _setError('تم الدخول في الوضع المحلي (بدون إنترنت)');
          return true;
        } else {
          _setError(offlineResult['message']);
        }
      }

      return false;
    } catch (e) {
      _setError('خطأ في تسجيل الدخول: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register Student with fallback to offline mode
  Future<bool> registerStudent({
    required String name,
    required String email,
    required String password,
    required String studentId,
    required String phone,
    required String department,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final studentData = {
        'name': name,
        'email': email,
        'password': password,
        'student_id': studentId,
        'phone': phone,
        'department': department,
        'role': 'student',
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

        final offlineResult = await _offlineService.register(studentData);

        if (offlineResult['success']) {
          _isOfflineMode = true;
          _setError('تم إنشاء الحساب في الوضع المحلي');
          return true;
        } else {
          _setError(offlineResult['message']);
        }
      }

      return false;
    } catch (e) {
      _setError('خطأ في التسجيل: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register Teacher with fallback to offline mode
  Future<bool> registerTeacher({
    required String name,
    required String email,
    required String password,
    required String teacherId,
    required String phone,
    required String department,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final teacherData = {
        'name': name,
        'email': email,
        'password': password,
        'teacher_id': teacherId,
        'phone': phone,
        'department': department,
        'role': 'teacher',
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

        final offlineResult = await _offlineService.register(teacherData);

        if (offlineResult['success']) {
          _isOfflineMode = true;
          _setError('تم إنشاء الحساب في الوضع المحلي');
          return true;
        } else {
          _setError(offlineResult['message']);
        }
      }

      return false;
    } catch (e) {
      _setError('خطأ في التسجيل: $e');
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
      notifyListeners();
    } catch (e) {
      // Even if logout fails on server, clear local data
      _currentUser = null;
      _isOfflineMode = false;
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