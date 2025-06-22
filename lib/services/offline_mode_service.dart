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
      'name': 'Ahmed Mohamed',
      'email': 'student@test.com',
      'password': '123456',
      'role': 'student',
    },
    {
      'id': '2',
      'name': 'Dr. Sara Ahmed',
      'email': 'teacher@test.com',
      'password': '123456',
      'role': 'teacher',
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
  Future<Map<String, dynamic>> login(String email, String password, String userType) async {
    await initializeOfflineData();

    final prefs = await SharedPreferences.getInstance();
    final usersData = prefs.getString(_usersKey);

    if (usersData != null) {
      final List<dynamic> users = jsonDecode(usersData);

      final user = users.firstWhere(
            (u) => u['email'] == email && u['password'] == password && u['role'] == userType,
        orElse: () => null,
      );

      if (user != null) {
        // Store current user
        await prefs.setString(_currentUserKey, jsonEncode(user));
        // Generate fake token
        await prefs.setString('access_token', 'offline_token_${DateTime.now().millisecondsSinceEpoch}');

        return {
          'success': true,
          'data': {
            'user': user,
            'access_token': 'offline_token_${DateTime.now().millisecondsSinceEpoch}',
          }
        };
      }
    }

    return {
      'success': false,
      'message': 'Invalid email or password'
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
        'message': 'Email already exists'
      };
    }

    // Add new user
    userData['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    users.add(userData);

    // Save updated users
    await prefs.setString(_usersKey, jsonEncode(users));

    return {
      'success': true,
      'message': 'Account created successfully'
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
    await prefs.remove('access_token');
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
            'description': 'Introduction to Flutter Development',
            'teacher_id': '2',
            'teacher_name': 'Dr. Sara Ahmed',
            'credit_hours': 3,

          },
          {
            'id': '2',
            'name': 'Database Systems',
            'code': 'CS201',
            'description': 'Database Management Systems',
            'teacher_id': '2',
            'teacher_name': 'Dr. Sara Ahmed',
            'credit_hours': 3,
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
        'qr_code': 'COURSE_${courseId}_SESSION_${DateTime.now().millisecondsSinceEpoch}',
        'course_id': courseId,
        'session_id': DateTime.now().millisecondsSinceEpoch.toString(),
        'generated_at': DateTime.now().toIso8601String(),
        'expires_at': DateTime.now().add(Duration(hours: 2)).toIso8601String(),
      }
    };
  }

  Future<Map<String, dynamic>> scanQRCode(String qrCode) async {
    await Future.delayed(Duration(seconds: 1));

    return {
      'success': true,
      'data': {
        'message': 'Attendance marked successfully',
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
            'sender_name': 'Dr. Sara Ahmed',
            'sender_role': 'teacher',
            'message': 'Welcome to the course',
            'timestamp': DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
          },
          {
            'id': '2',
            'course_id': courseId,
            'sender_id': '2',
            'sender_name': 'Dr. Sara Ahmed',
            'sender_role': 'teacher',
            'message': 'Please review the first lecture',
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
        'message': 'Message sent successfully'
      }
    };
  }

  // New methods for grades and attendance
  Future<Map<String, dynamic>> getGrades() async {
    await Future.delayed(Duration(milliseconds: 500));

    return {
      'success': true,
      'data': {
        'grades': [
          {
            'course_name': 'Flutter Development',
            'final': 45,
            'year_work': 9,
            'practical': 14,
            'oral': 5,
            'mid_term': 28,
            'total': 101,
            'grade': 'A'
          },
          {
            'course_name': 'Database Systems',
            'final': 40,
            'year_work': 8,
            'practical': 12,
            'oral': 4,
            'mid_term': 25,
            'total': 89,
            'grade': 'B+'
          },
        ]
      }
    };
  }

  Future<Map<String, dynamic>> getAttendanceHistory() async {
    await Future.delayed(Duration(milliseconds: 500));

    final List<Map<String, dynamic>> attendanceRecords = [];
    final now = DateTime.now();

    // Generate 15 attendance records for demonstration
    for (int i = 0; i < 15; i++) {
      final date = now.subtract(Duration(days: i * 3));
      final status = i % 10 < 7 ? 'present' : (i % 10 < 9 ? 'late' : 'absent');

      attendanceRecords.add({
        'id': '$i',
        'course_name': i % 2 == 0 ? 'Flutter Development' : 'Database Systems',
        'date': date.toIso8601String(),
        'status': status,
        'check_in_time': status != 'absent' ? date.add(Duration(hours: 9, minutes: 15 + (i % 30))).toIso8601String() : null,
      });
    }

    return {
      'success': true,
      'data': {
        'attendance': attendanceRecords
      }
    };
  }

  Future<Map<String, dynamic>> getCourseSessions(String courseId) async {
    await Future.delayed(Duration(milliseconds: 500));

    return {
      'success': true,
      'data': {
        'sessions': [
          {
            'id': '1',
            'name': 'Session 1',
            'date': DateTime.now().subtract(Duration(days: 7)).toIso8601String(),
          },
          {
            'id': '2',
            'name': 'Session 2',
            'date': DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
          },
          {
            'id': '3',
            'name': 'Session 3',
            'date': DateTime.now().toIso8601String(),
          },
        ]
      }
    };
  }
}