import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final ApiService _apiService = ApiService();
  List<Course> _courses = [];
  Map<String, List<AttendanceRecord>> _courseAttendance = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAttendanceHistory();
  }

  Future<void> _loadAttendanceHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _apiService.getTeacherCourses();

      if (result['success']) {
        final List<dynamic> coursesData = result['data']['courses'] ?? [];
        final courses = coursesData.map((course) => Course.fromJson(course)).toList();

        setState(() {
          _courses = courses;
        });

        // Load attendance for each course
        for (var course in courses) {
          await _loadCourseAttendance(course.id);
        }
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'فشل في تحميل المواد';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ في تحميل البيانات: $e';
      });

      // Load dummy data as fallback
      _loadDummyData();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCourseAttendance(String courseId) async {
    try {
      final result = await _apiService.getAttendanceHistory(courseId);

      if (result['success']) {
        final List<dynamic> attendanceData = result['data']['attendance'] ?? [];
        final attendanceRecords = attendanceData.map((record) => AttendanceRecord.fromJson(record)).toList();

        setState(() {
          _courseAttendance[courseId] = attendanceRecords;
        });
      }
    } catch (e) {
      print('Error loading attendance for course $courseId: $e');
    }
  }

  void _loadDummyData() {
    // Dummy data for demonstration
    final List<Map<String, dynamic>> lectures = [
      {
        "id": "1",
        "courseId": "flutter_dev",
        "courseName": "Flutter Development",
        "title": "Introduction to Flutter",
        "date": "2024-02-13",
        "attendees": [
          {"id": "1001", "name": "Ahmed Mohamed", "status": "present", "checkInTime": "2024-02-13T09:15:00"},
          {"id": "1002", "name": "Khaled Ibrahim", "status": "present", "checkInTime": "2024-02-13T09:20:00"},
          {"id": "1003", "name": "Sarah Ali", "status": "late", "checkInTime": "2024-02-13T09:35:00"},
          {"id": "1004", "name": "Mahmoud Hassan", "status": "absent", "checkInTime": null},
        ]
      },
      {
        "id": "2",
        "courseId": "flutter_dev",
        "courseName": "Flutter Development",
        "title": "Widgets and Layouts",
        "date": "2024-02-15",
        "attendees": [
          {"id": "1001", "name": "Ahmed Mohamed", "status": "present", "checkInTime": "2024-02-15T09:10:00"},
          {"id": "1002", "name": "Khaled Ibrahim", "status": "absent", "checkInTime": null},
          {"id": "1003", "name": "Sarah Ali", "status": "present", "checkInTime": "2024-02-15T09:18:00"},
          {"id": "1004", "name": "Mahmoud Hassan", "status": "present", "checkInTime": "2024-02-15T09:25:00"},
        ]
      },
      {
        "id": "3",
        "courseId": "database_systems",
        "courseName": "Database Systems",
        "title": "SQL Basics",
        "date": "2024-02-16",
        "attendees": [
          {"id": "1010", "name": "Mona Hassan", "status": "present", "checkInTime": "2024-02-16T10:15:00"},
          {"id": "1011", "name": "Hager Ali", "status": "present", "checkInTime": "2024-02-16T10:20:00"},
          {"id": "1012", "name": "Omar Tarek", "status": "late", "checkInTime": "2024-02-16T10:40:00"},
        ]
      },
      {
        "id": "4",
        "courseId": "data_structures",
        "courseName": "Data Structures",
        "title": "Arrays and Lists",
        "date": "2024-02-17",
        "attendees": [
          {"id": "1015", "name": "Reham Gamal", "status": "present", "checkInTime": "2024-02-17T11:15:00"},
          {"id": "1016", "name": "Aisha Youssef", "status": "present", "checkInTime": "2024-02-17T11:18:00"},
          {"id": "1017", "name": "Mustafa Khaled", "status": "absent", "checkInTime": null},
          {"id": "1018", "name": "Nour Ahmed", "status": "present", "checkInTime": "2024-02-17T11:25:00"},
        ]
      },
    ];

    // Group lectures by course
    final Map<String, List<Map<String, dynamic>>> groupedLectures = {};
    final Set<String> courseIds = {};

    for (var lecture in lectures) {
      final courseId = lecture['courseId'];
      courseIds.add(courseId);

      if (!groupedLectures.containsKey(courseId)) {
        groupedLectures[courseId] = [];
      }
      groupedLectures[courseId]!.add(lecture);
    }

    // Create dummy courses
    setState(() {
      _courses = courseIds.map((courseId) {
        final lectureSample = lectures.firstWhere((l) => l['courseId'] == courseId);
        return Course(
          id: courseId,
          name: lectureSample['courseName'],
          code: courseId.substring(0, 3).toUpperCase(),
          description: '',
          teacherId: '1',
          teacherName: 'Dr. Ahmed',
          creditHours: 3,
          enrolledStudents: ['1001', '1002', '1003', '1004'],
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      child: Scaffold(
        body: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.history, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'سجل الحضور',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _loadAttendanceHistory,
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadAttendanceHistory,
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              )
                  : _courses.isEmpty
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school_outlined, size: 60, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'لا توجد مواد',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _courses.length,
                itemBuilder: (context, index) {
                  final course = _courses[index];
                  final attendanceRecords = _courseAttendance[course.id] ?? [];

                  return _buildCourseCard(course, attendanceRecords);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(Course course, List<AttendanceRecord> attendanceRecords) {
    // Calculate stats
    final totalLectures = _getTotalLecturesForCourse(course.id);
    final totalStudents = course.enrolledStudents.length;
    final averageAttendance = _calculateAverageAttendance(course.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showCourseAttendanceDetails(course),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.book,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          course.code,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),

              const SizedBox(height: 16),

              // Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'المحاضرات',
                      '$totalLectures',
                      Colors.blue,
                      Icons.event,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      'الطلاب',
                      '$totalStudents',
                      Colors.green,
                      Icons.people,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      'متوسط الحضور',
                      '${averageAttendance.round()}%',
                      Colors.orange,
                      Icons.trending_up,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showCourseAttendanceDetails(Course course) {
    // Get dummy lecture data for this course
    final lectures = _getDummyLecturesForCourse(course.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(ctx).size.height * 0.8,
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      course.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'سجل المحاضرات والحضور',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Lectures list
              Expanded(
                child: lectures.isEmpty
                    ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_note, size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'لا توجد محاضرات مسجلة',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: lectures.length,
                  itemBuilder: (context, index) {
                    final lecture = lectures[index];
                    return _buildLectureCard(lecture);
                  },
                ),
              ),

              // Close button
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('إغلاق'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLectureCard(Map<String, dynamic> lecture) {
    final List<dynamic> attendees = lecture['attendees'] ?? [];
    final presentCount = attendees.where((a) => a['status'] == 'present').length;
    final lateCount = attendees.where((a) => a['status'] == 'late').length;
    final absentCount = attendees.where((a) => a['status'] == 'absent').length;
    final totalStudents = attendees.length;
    final attendanceRate = totalStudents > 0 ? (presentCount + lateCount) / totalStudents * 100 : 0;

    Color rateColor;
    if (attendanceRate >= 80) {
      rateColor = Colors.green;
    } else if (attendanceRate >= 60) {
      rateColor = Colors.orange;
    } else {
      rateColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showLectureAttendees(lecture),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lecture info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.event,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lecture['title'] ?? 'محاضرة',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          _formatLectureDate(lecture['date']),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: rateColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: rateColor),
                    ),
                    child: Text(
                      '${attendanceRate.round()}%',
                      style: TextStyle(
                        color: rateColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Attendance summary
              Row(
                children: [
                  _buildAttendanceChip('حاضر', presentCount, Colors.green),
                  const SizedBox(width: 8),
                  _buildAttendanceChip('متأخر', lateCount, Colors.orange),
                  const SizedBox(width: 8),
                  _buildAttendanceChip('غائب', absentCount, Colors.red),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$label: $count',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showLectureAttendees(Map<String, dynamic> lecture) {
    final List<dynamic> attendees = lecture['attendees'] ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(ctx).size.height * 0.7,
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      lecture['title'] ?? 'محاضرة',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatLectureDate(lecture['date']),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Attendees list
              Expanded(
                child: attendees.isEmpty
                    ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'لا يوجد طلاب في هذه المحاضرة',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: attendees.length,
                  itemBuilder: (context, index) {
                    final attendee = attendees[index];
                    return _buildAttendeeListTile(attendee);
                  },
                ),
              ),

              // Close button
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('إغلاق'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttendeeListTile(Map<String, dynamic> attendee) {
    final String status = attendee['status'] ?? 'unknown';
    final String? checkInTime = attendee['checkInTime'];

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'present':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'حاضر';
        break;
      case 'absent':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'غائب';
        break;
      case 'late':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        statusText = 'متأخر';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = 'غير محدد';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: statusColor.withOpacity(0.2),
            child: Icon(
              Icons.person,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attendee['name'] ?? 'غير محدد',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'ID: ${attendee['id'] ?? 'غير محدد'}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                if (checkInTime != null)
                  Text(
                    'وقت الحضور: ${_formatCheckInTime(checkInTime)}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getTotalLecturesForCourse(String courseId) {
    return _getDummyLecturesForCourse(courseId).length;
  }

  double _calculateAverageAttendance(String courseId) {
    final lectures = _getDummyLecturesForCourse(courseId);
    if (lectures.isEmpty) return 0;

    double totalRate = 0;
    for (var lecture in lectures) {
      final attendees = lecture['attendees'] ?? [];
      final presentCount = attendees.where((a) => a['status'] == 'present').length;
      final lateCount = attendees.where((a) => a['status'] == 'late').length;
      final totalStudents = attendees.length;

      if (totalStudents > 0) {
        totalRate += (presentCount + lateCount) / totalStudents * 100;
      }
    }

    return lectures.isNotEmpty ? totalRate / lectures.length : 0;
  }

  List<Map<String, dynamic>> _getDummyLecturesForCourse(String courseId) {
    // This would normally come from API
    final allLectures = [
      {
        "id": "1",
        "courseId": "flutter_dev",
        "title": "Introduction to Flutter",
        "date": "2024-02-13",
        "attendees": [
          {"id": "1001", "name": "Ahmed Mohamed", "status": "present", "checkInTime": "2024-02-13T09:15:00"},
          {"id": "1002", "name": "Khaled Ibrahim", "status": "present", "checkInTime": "2024-02-13T09:20:00"},
          {"id": "1003", "name": "Sarah Ali", "status": "late", "checkInTime": "2024-02-13T09:35:00"},
          {"id": "1004", "name": "Mahmoud Hassan", "status": "absent", "checkInTime": null},
        ]
      },
      {
        "id": "2",
        "courseId": "flutter_dev",
        "title": "Widgets and Layouts",
        "date": "2024-02-15",
        "attendees": [
          {"id": "1001", "name": "Ahmed Mohamed", "status": "present", "checkInTime": "2024-02-15T09:10:00"},
          {"id": "1002", "name": "Khaled Ibrahim", "status": "absent", "checkInTime": null},
          {"id": "1003", "name": "Sarah Ali", "status": "present", "checkInTime": "2024-02-15T09:18:00"},
          {"id": "1004", "name": "Mahmoud Hassan", "status": "present", "checkInTime": "2024-02-15T09:25:00"},
        ]
      },
    ];

    return allLectures.where((lecture) => lecture['courseId'] == courseId).toList();
  }

  String _formatLectureDate(String? dateStr) {
    if (dateStr == null) return 'تاريخ غير محدد';

    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
        'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
      ];

      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _formatCheckInTime(String timeStr) {
    try {
      final time = DateTime.parse(timeStr);
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timeStr;
    }
  }
}