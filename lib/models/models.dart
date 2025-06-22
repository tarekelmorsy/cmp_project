class User {
  final String id;
  final String name;
  final String email;
  final String role; // 'student' or 'teacher'
  final String? phone;
  final String? department;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.department,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      phone: json['phone'],
      department: json['department'],
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
    };
  }
}

class Course {
  final String id;
  final String name;
  final String code;
  final String? description;
  final String? teacherId;
  final String? teacherName;
  final int? creditHours;

  Course({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.teacherId,
    this.teacherName,
    this.creditHours,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'],
      teacherId: json['teacher_id']?.toString(),
      teacherName: json['teacher_name'],
      creditHours: json['credit_hours'],
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
    };
  }
}

class AttendanceRecord {
  final String id;
  final String courseId;
  final String courseName;
  final DateTime date;
  final String status; // 'present', 'absent', 'late'
  final DateTime? checkInTime;

  AttendanceRecord({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.date,
    required this.status,
    this.checkInTime,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id']?.toString() ?? '',
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
      timestamp: DateTime.parse(json['timestamp'] ?? json['created_at'] ?? DateTime.now().toIso8601String()),
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

class Session {
  final String id;
  final String name;
  final DateTime date;

  Session({
    required this.id,
    required this.name,
    required this.date,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
    };
  }
}

class Grade {
  final String courseName;
  final double? final_;
  final double? yearWork;
  final double? practical;
  final double? oral;
  final double? midTerm;
  final double? total;
  final String? grade;

  Grade({
    required this.courseName,
    this.final_,
    this.yearWork,
    this.practical,
    this.oral,
    this.midTerm,
    this.total,
    this.grade,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      courseName: json['course_name'] ?? '',
      final_: json['final']?.toDouble(),
      yearWork: json['year_work']?.toDouble(),
      practical: json['practical']?.toDouble(),
      oral: json['oral']?.toDouble(),
      midTerm: json['mid_term']?.toDouble(),
      total: json['total']?.toDouble(),
      grade: json['grade'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_name': courseName,
      'final': final_,
      'year_work': yearWork,
      'practical': practical,
      'oral': oral,
      'mid_term': midTerm,
      'total': total,
      'grade': grade,
    };
  }
}