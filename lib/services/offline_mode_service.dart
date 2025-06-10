import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class OfflineModeService {
  // Simulate offline data storage
  static const String _usersKey = 'offline_users';
  static const String _currentUserKey = 'current_user';

  // Default users for testing
  final List<Map<String, dynamic>> _defaultUsers = [
    {
      'id': '1',
      'name': 'أحمد محمد',
      'email': 'student@test.com',
      'password': '123456',
      'role': 'student',
      'student_id': 'ST001',
      'phone': '01234567890',
      'department': 'علوم الحاسوب',
    },
    {
      'id': '2',
      'name': 'د. سارة أحمد',
      'email': 'teacher@test.com',
      'password': '123456',
      'role': 'teacher',
      'teacher_id': 'TC001',
      'phone': '01987654321',
      'department': 'علوم الحاسوب',
    },
  ];

  // Initialize offline data
  Future<void> initializeOfflineData() async {
    final prefs = await SharedPreferences.getInstance();
    final usersData = prefs.getString(_usersKey);

    if (usersData == null) {
      // Store default users
      await prefs.setString(_usersKey, jsonEncode(_defaultUsers));
    }
  }

  // Offline Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    await initializeOfflineData();

    final prefs = await SharedPreferences.getInstance();
    final usersData = prefs.getString(_usersKey);

    if (usersData != null) {
      final List<dynamic> users = jsonDecode(usersData);

      final user = users.firstWhere(
            (u) => u['email'] == email && u['password'] == password,
        orElse: () => null,
      );

      if (user != null) {
        // Store current user
        await prefs.setString(_currentUserKey, jsonEncode(user));
        // Generate fake token
        await prefs.setString('auth_token', 'offline_token_${DateTime.now().millisecondsSinceEpoch}');

        return {
          'success': true,
          'data': {
            'user': user,
            'token': 'offline_token_${DateTime.now().millisecondsSinceEpoch}',
          }
        };
      }
    }

    return {
      'success': false,
      'message': 'البريد الإلكتروني أو كلمة المرور غير صحيحة'
    };
  }

  // Offline Registration
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    await initializeOfflineData();

    final prefs = await SharedPreferences.getInstance();
    final usersData = prefs.getString(_usersKey);

    List<dynamic> users = [];
    if (usersData != null) {
      users = jsonDecode(usersData);
    }

    // Check if email already exists
    final existingUser = users.firstWhere(
          (u) => u['email'] == userData['email'],
      orElse: () => null,
    );

    if (existingUser != null) {
      return {
        'success': false,
        'message': 'البريد الإلكتروني مستخدم بالفعل'
      };
    }

    // Add new user
    userData['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    users.add(userData);

    // Save updated users
    await prefs.setString(_usersKey, jsonEncode(users));

    return {
      'success': true,
      'message': 'تم إنشاء الحساب بنجاح'
    };
  }

  // Get current user
  Future<Map<String, dynamic>> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_currentUserKey);

    if (userData != null) {
      return {
        'success': true,
        'data': jsonDecode(userData)
      };
    }

    return {
      'success': false,
      'message': 'No user found'
    };
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    await prefs.remove('auth_token');
  }

  // Mock data for other features
  Future<Map<String, dynamic>> getStudentCourses() async {
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay

    return {
      'success': true,
      'data': {
        'courses': [
          {
            'id': '1',
            'name': 'Flutter Development',
            'code': 'CS101',
            'description': 'مقدمة في تطوير تطبيقات Flutter',
            'teacher_id': '2',
            'teacher_name': 'د. سارة أحمد',
            'credit_hours': 3,
            'enrolled_students': ['1']
          },
          {
            'id': '2',
            'name': 'Database Systems',
            'code': 'CS201',
            'description': 'أنظمة قواعد البيانات',
            'teacher_id': '2',
            'teacher_name': 'د. سارة أحمد',
            'credit_hours': 3,
            'enrolled_students': ['1']
          },
        ]
      }
    };
  }

  Future<Map<String, dynamic>> generateQRCode(String courseId) async {
    await Future.delayed(Duration(seconds: 2)); // Simulate generation time

    return {
      'success': true,
      'data': {
        'qr_data': 'COURSE_${courseId}_${DateTime.now().millisecondsSinceEpoch}',
        'course_id': courseId,
        'generated_at': DateTime.now().toIso8601String(),
        'expires_at': DateTime.now().add(Duration(hours: 2)).toIso8601String(),
      }
    };
  }

  Future<Map<String, dynamic>> markAttendance(String qrData) async {
    await Future.delayed(Duration(seconds: 1));

    return {
      'success': true,
      'data': {
        'message': 'تم تسجيل الحضور بنجاح',
        'timestamp': DateTime.now().toIso8601String(),
      }
    };
  }

  Future<Map<String, dynamic>> getChatMessages(String courseId) async {
    await Future.delayed(Duration(milliseconds: 500));

    return {
      'success': true,
      'data': {
        'messages': [
          {
            'id': '1',
            'course_id': courseId,
            'sender_id': '2',
            'sender_name': 'د. سارة أحمد',
            'sender_role': 'teacher',
            'message': 'مرحباً بكم في المادة',
            'timestamp': DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
          },
          {
            'id': '2',
            'course_id': courseId,
            'sender_id': '2',
            'sender_name': 'د. سارة أحمد',
            'sender_role': 'teacher',
            'message': 'يرجى مراجعة المحاضرة الأولى',
            'timestamp': DateTime.now().subtract(Duration(hours: 1)).toIso8601String(),
          },
        ]
      }
    };
  }

  Future<Map<String, dynamic>> sendChatMessage(String courseId, String message) async {
    await Future.delayed(Duration(seconds: 1));

    return {
      'success': true,
      'data': {
        'message': 'تم إرسال الرسالة بنجاح'
      }
    };
  }
}