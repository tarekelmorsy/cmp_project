import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../services/offline_mode_service.dart';
import '../models/models.dart';

class GradesScreen extends StatefulWidget {
  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  final ApiService _apiService = ApiService();
  final OfflineModeService _offlineService = OfflineModeService();
  List<Course> _courses = [];
  Map<String, List<Map<String, dynamic>>> _courseGrades = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      Map<String, dynamic> result;

      if (authProvider.isOfflineMode) {
        // Use offline service
        result = await _offlineService.getStudentCourses();
      } else {
        // Try API first, fallback to offline
        try {
          result = await _offlineService.getStudentCourses();
        } catch (e) {
          print('API failed, using offline mode: $e');
          result = await _offlineService.getStudentCourses();
        }
      }

      if (result['success']) {
        final List<dynamic> coursesData = result['data']['courses'] ?? [];
        setState(() {
          _courses = coursesData.map((course) => Course.fromJson(course)).toList();
        });

        // Load grades for each course
        await _loadGradesForCourses();
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to load courses';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading data: $e';
      });

      // Load dummy data as fallback
      _loadDummyGrades();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadGradesForCourses() async {
    // This would be called if the API has a grades endpoint
    // For now, we'll use dummy data
    _loadDummyGrades();
  }

  void _loadDummyGrades() {
    // Dummy data for demonstration
    final List<Map<String, dynamic>> subjects = [
      {
        "subject": "Flutter Development",
        "exams": [
          {"examName": "Final", "score": 45, "grade": "A"},
          {"examName": "YearWork", "score": 9, "grade": "B+"},
          {"examName": "Practical", "score": 14, "grade": "B"},
          {"examName": "Oral", "score": 5, "grade": "C+"},
          {"examName": "MidTerm", "score": 28, "grade": "B+"},
        ]
      },
      {
        "subject": "Dart Programming",
        "exams": [
          {"examName": "Final", "score": 40, "grade": "A"},
          {"examName": "YearWork", "score": 10, "grade": "A+"},
          {"examName": "Practical", "score": 15, "grade": "A+"},
          {"examName": "Oral", "score": 7, "grade": "C"},
          {"examName": "MidTerm", "score": 27, "grade": "B"},
        ]
      },
      {
        "subject": "Data Structures",
        "exams": [
          {"examName": "Final", "score": 35, "grade": "B"},
          {"examName": "YearWork", "score": 8, "grade": "C+"},
          {"examName": "Practical", "score": 10, "grade": "B"},
          {"examName": "Oral", "score": 6, "grade": "C"},
          {"examName": "MidTerm", "score": 25, "grade": "B"},
        ]
      },
      {
        "subject": "Database Systems",
        "exams": [
          {"examName": "Final", "score": 44, "grade": "A"},
          {"examName": "YearWork", "score": 10, "grade": "A+"},
          {"examName": "Practical", "score": 12, "grade": "B"},
          {"examName": "Oral", "score": 8, "grade": "C"},
          {"examName": "MidTerm", "score": 28, "grade": "B+"},
        ]
      },
      {
        "subject": "Operating Systems",
        "exams": [
          {"examName": "Final", "score": 38, "grade": "B+"},
          {"examName": "YearWork", "score": 7, "grade": "C"},
          {"examName": "Practical", "score": 11, "grade": "B"},
          {"examName": "Oral", "score": 6, "grade": "C"},
          {"examName": "MidTerm", "score": 29, "grade": "B"},
        ]
      },
    ];

    setState(() {
      for (var subject in subjects) {
        _courseGrades[subject["subject"]] =
        List<Map<String, dynamic>>.from(subject["exams"]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          color: Colors.white,
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
                      const Icon(Icons.school, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        'My Grades',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (authProvider.isOfflineMode) ...[
                        const SizedBox(width: 8),
                        // Offline badge (commented out for now)
                      ],
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: _loadGrades,
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
                        Icon(
                          authProvider.isOfflineMode
                              ? Icons.wifi_off
                              : Icons.error,
                          size: 60,
                          color: authProvider.isOfflineMode
                              ? Colors.orange
                              : Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          authProvider.isOfflineMode
                              ? 'The app is running in offline mode'
                              : _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: authProvider.isOfflineMode
                                ? Colors.orange
                                : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadGrades,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                      : _courseGrades.isEmpty
                      ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.grade,
                            size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No grades available at the moment',
                          style: TextStyle(
                              color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    itemCount: _courseGrades.length,
                    itemBuilder: (context, index) {
                      final courseName =
                      _courseGrades.keys.elementAt(index);
                      final grades = _courseGrades[courseName]!;

                      // Calculate total grade
                      int totalScore = grades.fold(
                          0,
                              (sum, exam) =>
                          sum + (exam["score"] as int));

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding:
                          const EdgeInsets.all(16),
                          title: Text(
                            courseName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text('Total: '),
                                  Text(
                                    '$totalScore',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                      _getTotalGradeColor(
                                          totalScore),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${grades.length} exams',
                                    style: const TextStyle(
                                        color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing:
                          const Icon(Icons.arrow_drop_down),
                          onTap: () =>
                              _showGradesBottomSheet(context,
                                  courseName, grades),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showGradesBottomSheet(BuildContext context, String courseName,
      List<Map<String, dynamic>> exams) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        int totalScore =
        exams.fold(0, (sum, exam) => sum + (exam["score"] as int));

        return Container(
          padding: EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                      courseName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total score: $totalScore',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Grades list
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: exams.length,
                  itemBuilder: (context, i) {
                    final exam = exams[i];
                    final examName = exam["examName"] as String;
                    final score = exam["score"] as int;
                    final grade = exam["grade"] as String;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          // Exam name
                          Expanded(
                            flex: 2,
                            child: Text(
                              _getExamNameEnglish(examName),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),

                          // Score
                          Expanded(
                            flex: 1,
                            child: Text(
                              '$score',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          // Grade
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getGradeColor(grade).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border:
                              Border.all(color: _getGradeColor(grade)),
                            ),
                            child: Text(
                              grade,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getGradeColor(grade),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getExamNameEnglish(String examName) {
    switch (examName.toLowerCase()) {
      case 'final':
        return 'Final Exam';
      case 'yearwork':
        return 'Year Work';
      case 'practical':
        return 'Practical';
      case 'oral':
        return 'Oral';
      case 'midterm':
        return 'Midterm';
      default:
        return examName;
    }
  }

  Color _getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A+':
      case 'A':
        return Colors.green;
      case 'B+':
      case 'B':
        return Colors.orange;
      case 'C+':
      case 'C':
        return Colors.red;
      case 'F':
        return Colors.purple;
      default:
        return Colors.blueGrey;
    }
  }

  Color _getTotalGradeColor(int totalScore) {
    if (totalScore >= 85) return Colors.green;
    if (totalScore >= 70) return Colors.orange;
    if (totalScore >= 50) return Colors.red;
    return Colors.grey;
  }
}
