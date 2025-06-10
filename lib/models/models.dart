class User {
  final String id;
  final String name;
  final String email;
  final String role; // 'student' or 'teacher'
  final String? phone;
  final String? department;
  final String? studentId;
  final String? teacherId;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.department,
    this.studentId,
    this.teacherId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      phone: json['phone'],
      department: json['department'],
      studentId: json['student_id'],
      teacherId: json['teacher_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'department': department,
      'student_id': studentId,
      'teacher_id': teacherId,
    };
  }
}

class Course {
  final String id;
  final String name;
  final String code;
  final String description;
  final String teacherId;
  final String teacherName;
  final int creditHours;
  final List<String> enrolledStudents;

  Course({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.teacherId,
    required this.teacherName,
    required this.creditHours,
    required this.enrolledStudents,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      teacherId: json['teacher_id']?.toString() ?? '',
      teacherName: json['teacher_name'] ?? '',
      creditHours: json['credit_hours'] ?? 0,
      enrolledStudents: List<String>.from(json['enrolled_students'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'teacher_id': teacherId,
      'teacher_name': teacherName,
      'credit_hours': creditHours,
      'enrolled_students': enrolledStudents,
    };
  }
}

class AttendanceRecord {
  final String id;
  final String studentId;
  final String studentName;
  final String courseId;
  final String courseName;
  final DateTime date;
  final String status; // 'present', 'absent', 'late'
  final DateTime? checkInTime;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.courseId,
    required this.courseName,
    required this.date,
    required this.status,
    this.checkInTime,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      studentName: json['student_name'] ?? '',
      courseId: json['course_id']?.toString() ?? '',
      courseName: json['course_name'] ?? '',
      date: DateTime.parse(json['date']),
      status: json['status'] ?? '',
      checkInTime: json['check_in_time'] != null
          ? DateTime.parse(json['check_in_time'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'student_name': studentName,
      'course_id': courseId,
      'course_name': courseName,
      'date': date.toIso8601String(),
      'status': status,
      'check_in_time': checkInTime?.toIso8601String(),
    };
  }
}

class ChatMessage {
  final String id;
  final String courseId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.courseId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.message,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      courseId: json['course_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      senderName: json['sender_name'] ?? '',
      senderRole: json['sender_role'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_role': senderRole,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class QRAttendance {
  final String id;
  final String courseId;
  final String courseName;
  final String qrData;
  final DateTime generatedAt;
  final DateTime expiresAt;
  final bool isActive;

  QRAttendance({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.qrData,
    required this.generatedAt,
    required this.expiresAt,
    required this.isActive,
  });

  factory QRAttendance.fromJson(Map<String, dynamic> json) {
    return QRAttendance(
      id: json['id']?.toString() ?? '',
      courseId: json['course_id']?.toString() ?? '',
      courseName: json['course_name'] ?? '',
      qrData: json['qr_data'] ?? '',
      generatedAt: DateTime.parse(json['generated_at']),
      expiresAt: DateTime.parse(json['expires_at']),
      isActive: json['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'course_name': courseName,
      'qr_data': qrData,
      'generated_at': generatedAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'is_active': isActive,
    };
  }
}