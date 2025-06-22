import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://cmp-production-47d0.up.railway.app/api';
  static const Duration timeoutDuration = Duration(seconds: 10);

  // Get stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Save token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }
  // Get stored token
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('UserId');
  }

  // Save token
  Future<void> saveUserId(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('UserId', token);
  }

  // Remove token
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  // Get headers with token
  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Create Lecture (Teacher)
  Future<Map<String, dynamic>> createLecture(Map<String, dynamic> lectureData) async {
    try {
      final headers = await getHeaders();
      final response = await _makeRequest(
        http.post(
          Uri.parse('$baseUrl/lecture'),
          headers: headers,
          body: jsonEncode(lectureData),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to create lecture'};
      }
    } catch (e) {
      print('Create Lecture API Error: $e');
      return {'success': false, 'message': 'Connection error: ${e.toString()}'};
    }
  }

  // Mark Student Attendance
  Future<Map<String, dynamic>> markStudentAttendance(String lectureId, Map<String, dynamic> attendanceData) async {
    try {
      final headers = await getHeaders();
      final response = await _makeRequest(
        http.post(
          Uri.parse('$baseUrl/attendance/$lectureId'),
          headers: headers,
          body: jsonEncode(attendanceData),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to mark attendance'};
      }
    } catch (e) {
      print('Mark Attendance API Error: $e');
      return {'success': false, 'message': 'Connection error: ${e.toString()}'};
    }
  }
  // Add these methods to your existing ApiService class:

  // Get Course Chats (for both teacher and student)
  Future<Map<String, dynamic>> getCourseChats(String courseId) async {
    try {
      final headers = await getHeaders();
      final response = await _makeRequest(
        http.get(
          Uri.parse('$baseUrl/chats'),
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Filter messages by courseId
        if (data['success'] == true && data['data'] != null) {
          final allMessages = List<Map<String, dynamic>>.from(data['data']);
          final filteredMessages = allMessages
              .where((msg) => msg['course_id'].toString() == courseId)
              .toList();

          // Sort by created_at
          filteredMessages.sort((a, b) {
            final dateA = DateTime.parse(a['created_at']);
            final dateB = DateTime.parse(b['created_at']);
            return dateA.compareTo(dateB);
          });

          return {'success': true, 'data': filteredMessages};
        }
        return {'success': true, 'data': []};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to load messages'};
      }
    } catch (e) {
      print('Get Course Chats API Error: $e');
      return {'success': false, 'message': 'Connection error: ${e.toString()}'};
    }
  }

  // Send Course Chat (Teacher only)
  Future<Map<String, dynamic>> sendCourseChat(Map<String, dynamic> chatData) async {
    try {
      final headers = await getHeaders();
      final response = await _makeRequest(
        http.post(
          Uri.parse('$baseUrl/chats'),
          headers: headers,
          body: jsonEncode(chatData),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to send message'};
      }
    } catch (e) {
      print('Send Course Chat API Error: $e');
      return {'success': false, 'message': 'Connection error: ${e.toString()}'};
    }
  }
  // Helper method for HTTP requests with timeout and error handling
  Future<http.Response> _makeRequest(Future<http.Response> request) async {
    try {
      return await request.timeout(timeoutDuration);
    } catch (e) {
      print('API Request failed: $e');
      rethrow;
    }
  }

  // Student Login
  Future<Map<String, dynamic>> loginStudent(String email, String password) async {
    try {
      final response = await _makeRequest(
        http.post(
          Uri.parse('$baseUrl/students/login'),
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['access_token'] != null) {
          await saveToken(data['access_token']);
        }
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Login failed'};
      }
    } catch (e) {
      print('Student Login API Error: $e');
      rethrow;
    }
  }

  // Teacher Login
  Future<Map<String, dynamic>> loginTeacher(String email, String password) async {
    try {
      final response = await _makeRequest(
        http.post(
          Uri.parse('$baseUrl/teacher/login'),
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['access_token'] != null) {
          await saveToken(data['access_token']);

        }
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Login failed'};
      }
    } catch (e) {
      print('Teacher Login API Error: $e');
      rethrow;
    }
  }

  // Student Registration
  Future<Map<String, dynamic>> registerStudent(Map<String, dynamic> studentData) async {
    try {
      final response = await _makeRequest(
        http.post(
          Uri.parse('$baseUrl/students/register'),
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: jsonEncode(studentData),
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
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
          Uri.parse('$baseUrl/teacher/register'),
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: jsonEncode(teacherData),
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
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


  // Get Teacher Courses
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

  // Scan QR Code (Student)
  Future<Map<String, dynamic>> scanQRCode(String qrCode) async {
    try {
      final headers = await getHeaders();
      final response = await _makeRequest(
        http.post(
          Uri.parse('$baseUrl/students/scan-qr'),
          headers: headers,
          body: jsonEncode({'qr_code': qrCode}),
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to scan QR code'};
      }
    } catch (e) {
      print('Scan QR Code API Error: $e');
      rethrow;
    }
  }

  // Generate QR Code (Teacher)
  Future<Map<String, dynamic>> generateQRCode(String courseId, String sessionId) async {
    try {
      final headers = await getHeaders();
      final response = await _makeRequest(
        http.post(
          Uri.parse('$baseUrl/teacher/generate-qr'),
          headers: headers,
          body: jsonEncode({
            'course_id': courseId,
            'session_id': sessionId,
          }),
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to generate QR code'};
      }
    } catch (e) {
      print('Generate QR Code API Error: $e');
      rethrow;
    }
  }

  // Get Student Attendance
  Future<Map<String, dynamic>> getStudentAttendance() async {
    try {
      final headers = await getHeaders();
      final response = await _makeRequest(
        http.get(
          Uri.parse('$baseUrl/students/attendance'),
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
      print('Get Student Attendance API Error: $e');
      rethrow;
    }
  }

  // Get Teacher Attendance for Course
  Future<Map<String, dynamic>> getTeacherAttendance(String courseId) async {
    try {
      final headers = await getHeaders();
      final response = await _makeRequest(
        http.get(
          Uri.parse('$baseUrl/teacher/attendance/$courseId'),
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
      print('Get Teacher Attendance API Error: $e');
      rethrow;
    }
  }

  // // Get Student Grades
  // Future<Map<String, dynamic>> getStudentGrades() async {
  //   try {
  //     final headers = await getHeaders();
  //     final response = await _makeRequest(
  //       http.get(
  //         Uri.parse('$baseUrl/students/grades'),
  //         headers: headers,
  //       ),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       return {'success': true, 'data': data};
  //     } else {
  //       final error = jsonDecode(response.body);
  //       return {'success': false, 'message': error['message'] ?? 'Failed to load grades'};
  //     }
  //   } catch (e) {
  //     print('Get Student Grades API Error: $e');
  //     rethrow;
  //   }
  // }

  // Get Chat Messages (Teacher)
  Future<Map<String, dynamic>> getChatMessages(String courseId) async {
    try {
      final headers = await getHeaders();
      final response = await _makeRequest(
        http.get(
          Uri.parse('$baseUrl/teacher/messages/$courseId'),
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

  // Send Chat Message (Teacher)
  Future<Map<String, dynamic>> sendChatMessage(String courseId, String message) async {
    try {
      final headers = await getHeaders();
      final response = await _makeRequest(
        http.post(
          Uri.parse('$baseUrl/teacher/messages'),
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

  // Get Course Sessions (Teacher)
  Future<Map<String, dynamic>> getCourseSessions(String courseId) async {
    try {
      final headers = await getHeaders();
      final response = await _makeRequest(
        http.get(
          Uri.parse('$baseUrl/teacher/courses/$courseId/sessions'),
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to load sessions'};
      }
    } catch (e) {
      print('Get Course Sessions API Error: $e');
      rethrow;
    }
  }

  // Logout
  Future<Map<String, dynamic>> logout() async {
    try {
      await removeToken();
      return {'success': true, 'message': 'Logged out successfully'};
    } catch (e) {
      print('Logout Error: $e');
      return {'success': true, 'message': 'Logged out locally'};
    }
  }
}