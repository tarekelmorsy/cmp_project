import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class AbsenceScreen extends StatefulWidget {
  @override
  State<AbsenceScreen> createState() => _AbsenceScreenState();
}

class _AbsenceScreenState extends State<AbsenceScreen> {
  final ApiService _apiService = ApiService();
  List<Course> _courses = [];
  Map<String, List<AttendanceRecord>> _attendanceData = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final coursesResult = await _apiService.getStudentCourses();

      if (coursesResult['success']) {
        final List<dynamic> coursesData = coursesResult['data']['courses'] ?? [];
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
          _errorMessage = coursesResult['message'] ?? 'فشل في تحميل المواد';
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
          _attendanceData[courseId] = attendanceRecords;
        });
      }
    } catch (e) {
      // Handle individual course errors silently
      print('Error loading attendance for course $courseId: $e');
    }
  }

  void _loadDummyData() {
    // Dummy data for demonstration
    final List<Map<String, dynamic>> subjects = [
      {
        "subject": "Flutter Development",
        "absentDays": 3,
        "presentDays": 12,
        "totalClasses": 15,
      },
      {
        "subject": "Artificial Intelligence",
        "absentDays": 4,
        "presentDays": 11,
        "totalClasses": 15,
      },
      {
        "subject": "Software Engineering",
        "absentDays": 3,
        "presentDays": 12,
        "totalClasses": 15,
      },
      {
        "subject": "Web Development",
        "absentDays": 2,
        "presentDays": 13,
        "totalClasses": 15,
      },
      {
        "subject": "Cyber Security",
        "absentDays": 1,
        "presentDays": 14,
        "totalClasses": 15,
      },
      {
        "subject": "Cloud Computing",
        "absentDays": 5,
        "presentDays": 10,
        "totalClasses": 15,
      },
    ];

    // Convert dummy data to our format (this would normally come from API)
    setState(() {
      _courses = subjects.map((subject) => Course(
        id: subject['subject'].toString().toLowerCase().replaceAll(' ', '_'),
        name: subject['subject'],
        code: subject['subject'].toString().substring(0, 3).toUpperCase(),
        description: '',
        teacherId: '1',
        teacherName: 'Dr. Ahmed',
        creditHours: 3,
        enrolledStudents: [],
      )).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 649,
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
                  const Icon(Icons.event_busy, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'حالة الحضور والغياب',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _loadAttendanceData,
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
                      onPressed: _loadAttendanceData,
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
                      'لا توجد مواد مسجلة',
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
                  return _buildCourseAttendanceCard(course);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseAttendanceCard(Course course) {
    // Calculate attendance stats (would normally come from API)
    final attendanceRecords = _attendanceData[course.id] ?? [];

    // If no real data, use dummy calculations
    int absentDays = 0;
    int presentDays = 0;
    int totalClasses = 15; // Default total classes

    if (attendanceRecords.isNotEmpty) {
      presentDays = attendanceRecords.where((record) => record.status == 'present').length;
      absentDays = attendanceRecords.where((record) => record.status == 'absent').length;
      totalClasses = attendanceRecords.length;
    } else {
      // Use dummy data calculation
      absentDays = (course.name.length % 5) + 1; // Simple dummy calculation
      presentDays = totalClasses - absentDays;
    }

    final attendancePercentage = totalClasses > 0 ? (presentDays / totalClasses * 100).round() : 0;
    final remainingAllowedAbsences = (totalClasses * 0.25).floor() - absentDays; // 25% allowed absence

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (attendancePercentage >= 75) {
      statusColor = Colors.green;
      statusText = 'حضور جيد';
      statusIcon = Icons.check_circle;
    } else if (attendancePercentage >= 60) {
      statusColor = Colors.orange;
      statusText = 'تحذير';
      statusIcon = Icons.warning;
    } else {
      statusColor = Colors.red;
      statusText = 'خطر رسوب';
      statusIcon = Icons.error;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showAttendanceDetails(course, attendanceRecords),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course name and status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      course.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Attendance stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'الحضور',
                      '$presentDays',
                      Colors.green,
                      Icons.check,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      'الغياب',
                      '$absentDays',
                      Colors.red,
                      Icons.close,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      'النسبة',
                      '$attendancePercentage%',
                      statusColor,
                      Icons.percent,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Remaining absences warning
              if (remainingAllowedAbsences <= 2)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          remainingAllowedAbsences > 0
                              ? 'يمكنك الغياب $remainingAllowedAbsences مرة أخرى فقط'
                              : 'تجاوزت الحد المسموح للغياب',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // Progress bar
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: attendancePercentage / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
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
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showAttendanceDetails(Course course, List<AttendanceRecord> records) {
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
                child: Text(
                  course.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 16),

              // Attendance records
              Expanded(
                child: records.isEmpty
                    ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_note, size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'لا توجد سجلات حضور متاحة',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return _buildAttendanceRecordTile(record);
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

  Widget _buildAttendanceRecordTile(AttendanceRecord record) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (record.status) {
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
        statusText = record.status;
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
          Icon(statusIcon, color: statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(record.date),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (record.checkInTime != null)
                  Text(
                    'وقت الحضور: ${_formatTime(record.checkInTime!)}',
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
            child: Text(
              statusText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
