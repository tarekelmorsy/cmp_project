import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api'; // ضع رابط الـ API هنا
  static const Duration timeoutDuration = Duration(seconds: 5); // Timeout قصير للاختبار السريع

  // Get stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Save token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Remove token
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Get headers with token
  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Helper method for HTTP requests with timeout and error handling
  Future<http.Response> _makeRequest(Future<http.Response> request) async {
    try {
      return await request.timeout(timeoutDuration);
    } catch (e) {
      print('API Request failed: $e');
      rethrow; // Re-throw to be caught by calling method
    }
  }

  // Student/Teacher Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _makeRequest(
        http.post(
          Uri.parse('$baseUrl/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Login failed'};
      }
    } catch (e) {
      print('Login API Error: $e');
      // لا نرجع error هنا، بل نخلي الـ AuthProvider يتعامل مع الـ exception
      rethrow;
    }
  }

  // Student Registration
  Future<Map<String, dynamic>> registerStudent(Map<String, dynamic> studentData) async {
    try {
      final response = await _makeRequest(
        http.post(
          Uri.parse('$baseUrl/register/student'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(studentData),
        ),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Registration failed'};
      }
    } catch (e) {
      print('Student Registration API Error: $e');
      rethrow;
    }
  }

  // Teacher Registration
  Future<Map<String, dynamic>> registerTeacher(Map<String, dynamic> teacherData) async {
    try {
      final response = await _makeRequest(
        http.post(
          Uri.parse('$baseUrl/register/teacher'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(teacherData),
        ),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Registration failed'};
      }
    } catch (e) {
      print('Teacher Registration API Error: $e');
      rethrow;
    }
  }

  // Get Courses (for student)
  Future<Map<String, dynamic>> getStudentCourses() async {
    try {
      final headers = await getHeaders();
      final response = await _makeRequest(
        http.get(
          Uri.parse('$baseUrl/student/courses'),
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to load courses'};
      }
    } catch (e) {
      print('Get Student Courses API Error: $e');
      rethrow;
    }
  }

  // Get Courses (for teacher)
  Future<Map<String, dynamic>> getTeacherCourses() async {
    try {
      final headers = await getHeaders();
      final response = await _makeRequest(
        http.get(
          Uri.parse('$baseUrl/teacher/courses'),
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to load courses'};
      }
    } catch (e) {
      print('Get Teacher Courses API Error: $e');
      rethrow;
    }
  }

  // Mark Attendance (QR Code scan)
  Future<Map<String, dynamic>> markAttendance(String qrData) async {
    try {
      final headers = await getHeaders();
      final response = await _makeRequest(
        http.post(
          Uri.parse('$baseUrl/attendance/mark'),
          headers: headers,
          body: jsonEncode({'qr_data': qrData}),
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to mark attendance'};
      }
    } catch (e) {
      print('Mark Attendance API Error: $e');
      rethrow;
    }
  }

  // Get Attendance History
  Future<Map<String, dynamic>> getAttendanceHistory(String courseId) async {
    try {
      final headers = await getHeaders();
      final response = await _makeRequest(
        http.get(
          Uri.parse('$baseUrl/attendance/history/$courseId'),
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to load attendance'};
      }
    } catch (e) {
      print('Get Attendance History API Error: $e');
      rethrow;
    }
  }

  // Generate QR Code (for teacher)
  Future<Map<String, dynamic>> generateQRCode(String courseId) async {
    try {
      final headers = await getHeaders();
      final response = await _makeRequest(
        http.post(
          Uri.parse('$baseUrl/attendance/generate-qr'),
          headers: headers,
          body: jsonEncode({'course_id': courseId}),
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to generate QR'};
      }
    } catch (e) {
      print('Generate QR Code API Error: $e');
      rethrow;
    }
  }

  // Get Chat Messages
  Future<Map<String, dynamic>> getChatMessages(String courseId) async {
    try {
      final headers = await getHeaders();
      final response = await _makeRequest(
        http.get(
          Uri.parse('$baseUrl/chat/$courseId'),
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to load messages'};
      }
    } catch (e) {
      print('Get Chat Messages API Error: $e');
      rethrow;
    }
  }

  // Send Chat Message (teacher only)
  Future<Map<String, dynamic>> sendChatMessage(String courseId, String message) async {
    try {
      final headers = await getHeaders();
      final response = await _makeRequest(
        http.post(
          Uri.parse('$baseUrl/chat/send'),
          headers: headers,
          body: jsonEncode({
            'course_id': courseId,
            'message': message,
          }),
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to send message'};
      }
    } catch (e) {
      print('Send Chat Message API Error: $e');
      rethrow;
    }
  }

  // Get User Profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final headers = await getHeaders();
      final response = await _makeRequest(
        http.get(
          Uri.parse('$baseUrl/profile'),
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to load profile'};
      }
    } catch (e) {
      print('Get User Profile API Error: $e');
      rethrow;
    }
  }

  // Logout
  Future<Map<String, dynamic>> logout() async {
    try {
      final headers = await getHeaders();
      final response = await _makeRequest(
        http.post(
          Uri.parse('$baseUrl/logout'),
          headers: headers,
        ),
      );

      await removeToken();

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Logged out successfully'};
      } else {
        return {'success': true, 'message': 'Logged out locally'};
      }
    } catch (e) {
      print('Logout API Error: $e');
      await removeToken();
      return {'success': true, 'message': 'Logged out locally'};
    }
  }
}