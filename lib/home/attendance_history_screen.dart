import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';         // يحتوى على كلاس Course فقط
import '../providers/auth_provider.dart'; // لمؤشّر الوضع المحلى/أونلاين (اختيارى)

/*------------------------------------------------------------
 | AttendanceHistoryScreen – Local-Only (Dummy Data)
 *-----------------------------------------------------------*/
class AttendanceHistoryScreen extends StatefulWidget {
  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  /*────────────── بيانات وهميّة ثابتة ──────────────*/

  /// قائمة المقرّرات
  late final List<Course> _courses;

  /// كل محاضرات التطبيق (مجمّعة فى قائمة واحدة ثم نفلتر بالـ courseId)
  late final List<Map<String, dynamic>> _dummyLectures;

  @override
  void initState() {
    super.initState();
    _seedDummyData(); // إنشاء البيانات الوهمية مرّة واحدة
  }

  /*------------------------------------------------------------
   | إنشاء البيانات
   *-----------------------------------------------------------*/
  void _seedDummyData() {
    // ❶ المقرّرات
    _courses = [
      Course(
        id: 'flutter_dev',
        name: 'Flutter Development',
        code: 'FLU',
        description: '',
        teacherId: '1',
        teacherName: 'Dr. Ahmed',
        creditHours: 3,
      ),
      Course(
        id: 'database_systems',
        name: 'Database Systems',
        code: 'DBS',
        description: '',
        teacherId: '2',
        teacherName: 'Dr. Mona',
        creditHours: 3,
      ),
      Course(
        id: 'data_structures',
        name: 'Data Structures',
        code: 'DST',
        description: '',
        teacherId: '3',
        teacherName: 'Dr. Khaled',
        creditHours: 3,
      ),
    ];

    // ❷ المحاضرات + حضور الطلبة
    _dummyLectures = [
      {
        "id": "1",
        "courseId": "flutter_dev",
        "title": "Introduction to Flutter",
        "date": "2024-02-13",
        "attendees": [
          {
            "id": "1001",
            "name": "Ahmed Mohamed",
            "status": "present",
            "checkInTime": "2024-02-13T09:15:00"
          },
          {
            "id": "1002",
            "name": "Khaled Ibrahim",
            "status": "present",
            "checkInTime": "2024-02-13T09:20:00"
          },
          {
            "id": "1003",
            "name": "Sarah Ali",
            "status": "late",
            "checkInTime": "2024-02-13T09:35:00"
          },
          {
            "id": "1004",
            "name": "Mahmoud Hassan",
            "status": "absent",
            "checkInTime": null
          },
        ]
      },
      {
        "id": "2",
        "courseId": "flutter_dev",
        "title": "Widgets and Layouts",
        "date": "2024-02-15",
        "attendees": [
          {
            "id": "1001",
            "name": "Ahmed Mohamed",
            "status": "present",
            "checkInTime": "2024-02-15T09:10:00"
          },
          {
            "id": "1002",
            "name": "Khaled Ibrahim",
            "status": "absent",
            "checkInTime": null
          },
          {
            "id": "1003",
            "name": "Sarah Ali",
            "status": "present",
            "checkInTime": "2024-02-15T09:18:00"
          },
          {
            "id": "1004",
            "name": "Mahmoud Hassan",
            "status": "present",
            "checkInTime": "2024-02-15T09:25:00"
          },
        ]
      },
      {
        "id": "3",
        "courseId": "database_systems",
        "title": "SQL Basics",
        "date": "2024-02-16",
        "attendees": [
          {
            "id": "1010",
            "name": "Mona Hassan",
            "status": "present",
            "checkInTime": "2024-02-16T10:15:00"
          },
          {
            "id": "1011",
            "name": "Hager Ali",
            "status": "present",
            "checkInTime": "2024-02-16T10:20:00"
          },
          {
            "id": "1012",
            "name": "Omar Tarek",
            "status": "late",
            "checkInTime": "2024-02-16T10:40:00"
          },
        ]
      },
      {
        "id": "4",
        "courseId": "data_structures",
        "title": "Arrays and Lists",
        "date": "2024-02-17",
        "attendees": [
          {
            "id": "1015",
            "name": "Reham Gamal",
            "status": "present",
            "checkInTime": "2024-02-17T11:15:00"
          },
          {
            "id": "1016",
            "name": "Aisha Youssef",
            "status": "present",
            "checkInTime": "2024-02-17T11:18:00"
          },
          {
            "id": "1017",
            "name": "Mustafa Khaled",
            "status": "absent",
            "checkInTime": null
          },
          {
            "id": "1018",
            "name": "Nour Ahmed",
            "status": "present",
            "checkInTime": "2024-02-17T11:25:00"
          },
        ]
      },
    ];
  }

  /*------------------------------------------------------------
   | واجهة المستخدم
   *-----------------------------------------------------------*/
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      // فى حالة عدم استخدام AuthProvider يمكنك استبداله بـ Builder وإزالة isOfflineMode
      builder: (context, authProvider, child) {
        return Scaffold(
          body: Column(
            children: [
              /*──────── Header ────────*/
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
                      onPressed: () => setState(() {}), // مجرد إعادة بناء للواجهة
                    ),
                  ],
                ),
              ),

              /*──────── Courses List ────────*/
              Expanded(
                child: _courses.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _courses.length,
                  itemBuilder: (context, index) {
                    final course = _courses[index];
                    return _buildCourseCard(course);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /*------------------------------------------------------------
   |   Widgets مساعدة
   *-----------------------------------------------------------*/
  Widget _buildEmptyState() => const Center(
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
  );

  /*──────────── Course Card ────────────*/
  Widget _buildCourseCard(Course course) {
    final totalLectures = _getTotalLecturesForCourse(course.id);
    final averageAttendance = _calculateAverageAttendance(course.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showCourseAttendanceDetails(course),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /*── عنوان المقرر ──*/
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.book,
                        color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(course.code,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                ],
              ),

              const SizedBox(height: 16),

              /*── إحصاءات ──*/
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                        'المحاضرات', '$totalLectures', Colors.blue, Icons.event),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard('متوسط الحضور',
                        '${averageAttendance.round()}%', Colors.orange, Icons.trending_up),
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
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          Text(label,
              style: TextStyle(color: color, fontSize: 10),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  /*──────────── Bottom-Sheet تفاصيل مقرر ────────────*/
  void _showCourseAttendanceDetails(Course course) {
    final lectures = _getLecturesForCourse(course.id);

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
              /* Header */
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(course.name,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 4),
                    const Text('سجل المحاضرات والحضور',
                        style: TextStyle(fontSize: 14, color: Colors.white70)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              /* Lectures list */
              Expanded(
                child: lectures.isEmpty
                    ? _buildNoLectures()
                    : ListView.builder(
                  itemCount: lectures.length,
                  itemBuilder: (context, index) =>
                      _buildLectureCard(lectures[index]),
                ),
              ),

              /* Close */
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

  Widget _buildNoLectures() => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.event_note, size: 60, color: Colors.grey),
        SizedBox(height: 16),
        Text('لا توجد محاضرات مسجلة',
            style: TextStyle(color: Colors.grey, fontSize: 16)),
      ],
    ),
  );

  /*──────────── Lecture Card ────────────*/
  Widget _buildLectureCard(Map<String, dynamic> lecture) {
    final attendees = lecture['attendees'] as List<dynamic>;
    final present = attendees.where((a) => a['status'] == 'present').length;
    final late = attendees.where((a) => a['status'] == 'late').length;
    final absent = attendees.where((a) => a['status'] == 'absent').length;
    final total = attendees.length;
    final rate = total > 0 ? (present + late) / total * 100 : 0;

    Color rateColor =
    rate >= 80 ? Colors.green : rate >= 60 ? Colors.orange : Colors.red;

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
              /* Info */
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.event,
                        color: Theme.of(context).primaryColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lecture['title'] ?? 'محاضرة',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(_formatLectureDate(lecture['date']),
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: rateColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: rateColor),
                    ),
                    child: Text('${rate.round()}%',
                        style: TextStyle(
                            color: rateColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              /* Summary */
              Row(
                children: [
                  _buildAttendanceChip('حاضر', present, Colors.green),
                  const SizedBox(width: 8),
                  _buildAttendanceChip('متأخر', late, Colors.orange),
                  const SizedBox(width: 8),
                  _buildAttendanceChip('غائب', absent, Colors.red),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceChip(String label, int count, Color color) => Container(
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
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text('$label: $count',
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    ),
  );

  /*──────────── Bottom-Sheet قائمة الطلاب ────────────*/
  void _showLectureAttendees(Map<String, dynamic> lecture) {
    final attendees = lecture['attendees'] as List<dynamic>;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(ctx).size.height * 0.7,
          child: Column(
            children: [
              /* Header */
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(lecture['title'] ?? 'محاضرة',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(_formatLectureDate(lecture['date']),
                        style: const TextStyle(
                            fontSize: 14, color: Colors.white70)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              /* Students */
              Expanded(
                child: attendees.isEmpty
                    ? _buildNoStudents()
                    : ListView.builder(
                  itemCount: attendees.length,
                  itemBuilder: (context, index) =>
                      _buildAttendeeTile(attendees[index]),
                ),
              ),

              /* Close */
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

  Widget _buildNoStudents() => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.people_outline, size: 60, color: Colors.grey),
        SizedBox(height: 16),
        Text('لا يوجد طلاب في هذه المحاضرة',
            style: TextStyle(color: Colors.grey, fontSize: 16)),
      ],
    ),
  );

  Widget _buildAttendeeTile(Map<String, dynamic> a) {
    final status = a['status'];
    final time = a['checkInTime'];

    Color color;
    IconData icon;
    String text;

    switch (status) {
      case 'present':
        color = Colors.green;
        icon = Icons.check_circle;
        text = 'حاضر';
        break;
      case 'late':
        color = Colors.orange;
        icon = Icons.access_time;
        text = 'متأخر';
        break;
      case 'absent':
        color = Colors.red;
        icon = Icons.cancel;
        text = 'غائب';
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
        text = 'غير محدد';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(Icons.person, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a['name'] ?? 'غير محدد',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Text('ID: ${a['id'] ?? ''}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
                if (time != null)
                  Text('وقت الحضور: ${_formatTime(time)}',
                      style:
                      const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(text,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /*------------------------------------------------------------
   |   Helpers
   *-----------------------------------------------------------*/
  List<Map<String, dynamic>> _getLecturesForCourse(String courseId) =>
      _dummyLectures
          .where((lecture) => lecture['courseId'] == courseId)
          .toList();

  int _getTotalLecturesForCourse(String courseId) =>
      _getLecturesForCourse(courseId).length;

  double _calculateAverageAttendance(String courseId) {
    final lectures = _getLecturesForCourse(courseId);
    if (lectures.isEmpty) return 0;

    double total = 0;
    for (var lecture in lectures) {
      final attendees = lecture['attendees'] as List<dynamic>;
      final present =
          attendees.where((a) => a['status'] == 'present').length;
      final late =
          attendees.where((a) => a['status'] == 'late').length;
      final count = attendees.length;
      if (count > 0) total += (present + late) / count * 100;
    }
    return total / lectures.length;
  }

  String _formatLectureDate(String? s) {
    if (s == null) return 'تاريخ غير محدد';
    final date = DateTime.tryParse(s);
    if (date == null) return s;
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(String s) {
    final t = DateTime.tryParse(s);
    if (t == null) return s;
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }
}
