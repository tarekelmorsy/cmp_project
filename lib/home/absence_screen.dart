import 'package:flutter/material.dart';

class AbsenceScreen extends StatefulWidget {
  @override
  State<AbsenceScreen> createState() => _AbsenceScreenState();
}

class _AbsenceScreenState extends State<AbsenceScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Local course data
  final List<Map<String, dynamic>> _coursesData = [
    {
      "id": "1",
      "name": "Introduction to Programming",
      "code": "CS101",
      "icon": Icons.code,
      "color": Colors.blue,
      "totalClasses": 15,
      "presentDays": 12,
      "absentDays": 3,
      "lateDays": 1,
      "attendance": [
        {"date": "2024-12-20", "status": "present", "checkIn": "09:15"},
        {"date": "2024-12-18", "status": "present", "checkIn": "09:10"},
        {"date": "2024-12-15", "status": "absent"},
        {"date": "2024-12-13", "status": "late", "checkIn": "09:45"},
        {"date": "2024-12-11", "status": "present", "checkIn": "09:05"},
      ]
    },
    {
      "id": "2",
      "name": "Data Structures & Algorithms",
      "code": "CS201",
      "icon": Icons.account_tree,
      "color": Colors.green,
      "totalClasses": 15,
      "presentDays": 11,
      "absentDays": 4,
      "lateDays": 2,
      "attendance": [
        {"date": "2024-12-21", "status": "present", "checkIn": "11:10"},
        {"date": "2024-12-19", "status": "absent"},
        {"date": "2024-12-17", "status": "late", "checkIn": "11:35"},
        {"date": "2024-12-14", "status": "present", "checkIn": "11:15"},
        {"date": "2024-12-12", "status": "absent"},
      ]
    },
    {
      "id": "3",
      "name": "Database Management Systems",
      "code": "CS301",
      "icon": Icons.storage,
      "color": Colors.orange,
      "totalClasses": 15,
      "presentDays": 13,
      "absentDays": 2,
      "lateDays": 0,
      "attendance": [
        {"date": "2024-12-20", "status": "present", "checkIn": "13:05"},
        {"date": "2024-12-18", "status": "present", "checkIn": "13:10"},
        {"date": "2024-12-16", "status": "absent"},
        {"date": "2024-12-14", "status": "present", "checkIn": "13:12"},
        {"date": "2024-12-12", "status": "present", "checkIn": "13:08"},
      ]
    },
    {
      "id": "4",
      "name": "Computer Networks",
      "code": "CS401",
      "icon": Icons.lan,
      "color": Colors.purple,
      "totalClasses": 15,
      "presentDays": 14,
      "absentDays": 1,
      "lateDays": 1,
      "attendance": [
        {"date": "2024-12-21", "status": "present", "checkIn": "15:10"},
        {"date": "2024-12-19", "status": "present", "checkIn": "15:05"},
        {"date": "2024-12-17", "status": "late", "checkIn": "15:40"},
        {"date": "2024-12-15", "status": "present", "checkIn": "15:12"},
        {"date": "2024-12-13", "status": "absent"},
      ]
    },
    {
      "id": "5",
      "name": "Operating Systems",
      "code": "CS501",
      "icon": Icons.computer,
      "color": Colors.red,
      "totalClasses": 15,
      "presentDays": 10,
      "absentDays": 5,
      "lateDays": 3,
      "attendance": [
        {"date": "2024-12-20", "status": "absent"},
        {"date": "2024-12-18", "status": "late", "checkIn": "17:35"},
        {"date": "2024-12-16", "status": "absent"},
        {"date": "2024-12-14", "status": "present", "checkIn": "17:10"},
        {"date": "2024-12-12", "status": "absent"},
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Modern Header with Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withBlue(180),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.event_busy,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Attendance Status',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Track your presence',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Summary Cards
                    _buildSummaryCards(),
                  ],
                ),
              ),
            ),
          ),

          // Courses List
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _coursesData.length,
                itemBuilder: (context, index) {
                  return _buildCourseCard(_coursesData[index], index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    // Calculate totals
    int totalPresent = 0;
    int totalAbsent = 0;
    int totalLate = 0;

    for (var course in _coursesData) {
      totalPresent += course['presentDays'] as int;
      totalAbsent += course['absentDays'] as int;
      totalLate += course['lateDays'] as int;
    }

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Present',
            totalPresent.toString(),
            Colors.green,
            Icons.check_circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            'Absent',
            totalAbsent.toString(),
            Colors.red,
            Icons.cancel,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            'Late',
            totalLate.toString(),
            Colors.orange,
            Icons.access_time,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white30),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course, int index) {
    final attendancePercentage =
    ((course['presentDays'] + course['lateDays'] * 0.5) / course['totalClasses'] * 100).round();
    final remainingAllowedAbsences =
        (course['totalClasses'] * 0.25).floor() - course['absentDays'];

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (attendancePercentage >= 75) {
      statusColor = Colors.green;
      statusText = 'Good Standing';
      statusIcon = Icons.check_circle;
    } else if (attendancePercentage >= 60) {
      statusColor = Colors.orange;
      statusText = 'Warning';
      statusIcon = Icons.warning;
    } else {
      statusColor = Colors.red;
      statusText = 'At Risk';
      statusIcon = Icons.error;
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutBack,
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: course['color'].withOpacity(0.3),
        child: InkWell(
          onTap: () => _showAttendanceDetails(course),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: course['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        course['icon'],
                        color: course['color'],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            course['code'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.5)),
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
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Attendance Stats
                Row(
                  children: [
                    _buildStatChip(
                      Icons.check_circle,
                      '${course['presentDays']}',
                      'Present',
                      Colors.green,
                    ),
                    const SizedBox(width: 8),
                    _buildStatChip(
                      Icons.cancel,
                      '${course['absentDays']}',
                      'Absent',
                      Colors.red,
                    ),
                    const SizedBox(width: 8),
                    _buildStatChip(
                      Icons.access_time,
                      '${course['lateDays']}',
                      'Late',
                      Colors.orange,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: course['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$attendancePercentage%',
                        style: TextStyle(
                          color: course['color'],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Progress Bar
                Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 1000 + (index * 200)),
                      curve: Curves.easeOutCubic,
                      height: 8,
                      width: MediaQuery.of(context).size.width * attendancePercentage / 100 * 0.8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            statusColor,
                            statusColor.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Warning if needed
                if (remainingAllowedAbsences <= 2)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: Colors.orange,
                            size: 18
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            remainingAllowedAbsences > 0
                                ? 'You can only miss $remainingAllowedAbsences more classes'
                                : 'You have exceeded the allowed absences',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  color: color.withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAttendanceDetails(Map<String, dynamic> course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: course['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        course['icon'],
                        color: course['color'],
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course['name'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Attendance History',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Attendance Records
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: course['attendance'].length,
                  itemBuilder: (context, index) {
                    final record = course['attendance'][index];
                    return _buildAttendanceRecord(record);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttendanceRecord(Map<String, dynamic> record) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (record['status']) {
      case 'present':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Present';
        break;
      case 'absent':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Absent';
        break;
      case 'late':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time_filled;
        statusText = 'Late';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = record['status'];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(statusIcon, color: statusColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(record['date']),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    if (record['checkIn'] != null)
                      Text(
                        'Check-in: ${record['checkIn']}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${date.day} ${months[date.month - 1]}, ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}