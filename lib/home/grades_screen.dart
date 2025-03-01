import 'package:flutter/material.dart';

class GradesScreen extends StatelessWidget {
    GradesScreen({Key? key}) : super(key: key);

  /// لدينا 13 مادة، وكل مادة لها 5 اختبارات ثابتة:
  /// - Final
  /// - YearWork
  /// - Practical
  /// - Oral
  /// - MidTerm
  final List<Map<String, dynamic>> _subjects = [
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
    {
      "subject": "Computer Networks",
      "exams": [
        {"examName": "Final", "score": 40, "grade": "A"},
        {"examName": "YearWork", "score": 9, "grade": "B+"},
        {"examName": "Practical", "score": 10, "grade": "B"},
        {"examName": "Oral", "score": 8, "grade": "C"},
        {"examName": "MidTerm", "score": 26, "grade": "B"},
      ]
    },
    {
      "subject": "Algorithm Analysis",
      "exams": [
        {"examName": "Final", "score": 32, "grade": "B"},
        {"examName": "YearWork", "score": 8, "grade": "C+"},
        {"examName": "Practical", "score": 13, "grade": "B+"},
        {"examName": "Oral", "score": 7, "grade": "C"},
        {"examName": "MidTerm", "score": 27, "grade": "B"},
      ]
    },
    {
      "subject": "Software Engineering",
      "exams": [
        {"examName": "Final", "score": 37, "grade": "B"},
        {"examName": "YearWork", "score": 9, "grade": "B+"},
        {"examName": "Practical", "score": 10, "grade": "B"},
        {"examName": "Oral", "score": 9, "grade": "B+"},
        {"examName": "MidTerm", "score": 25, "grade": "B"},
      ]
    },
    {
      "subject": "Human Computer Interaction",
      "exams": [
        {"examName": "Final", "score": 30, "grade": "B"},
        {"examName": "YearWork", "score": 7, "grade": "C+"},
        {"examName": "Practical", "score": 12, "grade": "B+"},
        {"examName": "Oral", "score": 5, "grade": "C+"},
        {"examName": "MidTerm", "score": 24, "grade": "C"},
      ]
    },
    {
      "subject": "Machine Learning",
      "exams": [
        {"examName": "Final", "score": 45, "grade": "A+"},
        {"examName": "YearWork", "score": 9, "grade": "B+"},
        {"examName": "Practical", "score": 14, "grade": "B+"},
        {"examName": "Oral", "score": 10, "grade": "A+"},
        {"examName": "MidTerm", "score": 29, "grade": "B"},
      ]
    },
    {
      "subject": "Artificial Intelligence",
      "exams": [
        {"examName": "Final", "score": 42, "grade": "A"},
        {"examName": "YearWork", "score": 8, "grade": "C+"},
        {"examName": "Practical", "score": 10, "grade": "B"},
        {"examName": "Oral", "score": 7, "grade": "C"},
        {"examName": "MidTerm", "score": 27, "grade": "B"},
      ]
    },
    {
      "subject": "Cyber Security",
      "exams": [
        {"examName": "Final", "score": 40, "grade": "A"},
        {"examName": "YearWork", "score": 8, "grade": "C+"},
        {"examName": "Practical", "score": 12, "grade": "B"},
        {"examName": "Oral", "score": 6, "grade": "C"},
        {"examName": "MidTerm", "score": 25, "grade": "B"},
      ]
    },
    {
      "subject": "Cloud Computing",
      "exams": [
        {"examName": "Final", "score": 45, "grade": "A+"},
        {"examName": "YearWork", "score": 10, "grade": "A+"},
        {"examName": "Practical", "score": 14, "grade": "B+"},
        {"examName": "Oral", "score": 9, "grade": "B+"},
        {"examName": "MidTerm", "score": 30, "grade": "B+"},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 649,
      child: Scaffold(

        body: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: _subjects.length,
          itemBuilder: (context, index) {
            final subjectItem = _subjects[index];
            final subjectName = subjectItem["subject"] as String;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  subjectName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: () {
                  // عند الضغط على المادة، نعرض BottomSheet بالامتحانات
                  _showGradesBottomSheet(context, subjectItem);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  /// دالة لإظهار BottomSheet بالامتحانات الخاصة بالمادة
  void _showGradesBottomSheet(BuildContext context, Map<String, dynamic> subject) {
    final String subjectName = subject["subject"];
    final List<Map<String, dynamic>> exams =
    subject["exams"] as List<Map<String, dynamic>>;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
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
              // اسم المادة
              Text(
                subjectName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // عرض قائمة الامتحانات
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: exams.length,
                itemBuilder: (context, i) {
                  final exam = exams[i];
                  final examName = exam["examName"] as String;
                  final score = exam["score"] as int;
                  final grade = exam["grade"] as String;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(

                      children: [
                        // اسم الامتحان
                        Text(
                          examName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        // الدرجة
                        SizedBox(
                          width: 90,
                          child: Center(
                            child: Text(
                              'Score: $score',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // التقدير
                        SizedBox(

                          width: 30,
                          child: Center(
                            child: Text(
                              grade,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getGradeColor(grade),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // زر إغلاق البتم شيت
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// دالة مساعدة لتغيير لون الـ Grade حسب القيمة
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
}
