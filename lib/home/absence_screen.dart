import 'package:flutter/material.dart';

class AbsenceScreen extends StatelessWidget {
    AbsenceScreen({super.key});

  // قائمة المواد مع البيانات الوهمية
  final List<Map<String, dynamic>> _subjects = [
    {
      "subject": "Flutter",
      "absentDays": 3,
      "remainingDays": 6,
    },
    {
      "subject": "Dart",
      "absentDays": 2,
      "remainingDays": 7,
    },
    {
      "subject": "Database Systems",
      "absentDays": 4,
      "remainingDays": 5,
    },
    {
      "subject": "Operating Systems",
      "absentDays": 1,
      "remainingDays": 8,
    },
    {
      "subject": "Data Structures",
      "absentDays": 5,
      "remainingDays": 4,
    },
    {
      "subject": "Computer Networks",
      "absentDays": 3,
      "remainingDays": 6,
    },
    {
      "subject": "Algorithm Analysis",
      "absentDays": 2,
      "remainingDays": 8,
    },
    {
      "subject": "Machine Learning",
      "absentDays": 1,
      "remainingDays": 9,
    },
    {
      "subject": "Artificial Intelligence",
      "absentDays": 4,
      "remainingDays": 5,
    },
    {
      "subject": "Software Engineering",
      "absentDays": 3,
      "remainingDays": 7,
    },
    {
      "subject": "Web Development",
      "absentDays": 2,
      "remainingDays": 6,
    },
    {
      "subject": "Human Computer Interaction",
      "absentDays": 0,
      "remainingDays": 10,
    },
    {
      "subject": "Cloud Computing",
      "absentDays": 5,
      "remainingDays": 4,
    },
    {
      "subject": "Cyber Security",
      "absentDays": 1,
      "remainingDays": 9,
    },
    {
      "subject": "Discrete Mathematics",
      "absentDays": 2,
      "remainingDays": 7,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 649,
      child: Scaffold(
        
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _subjects.length,
          itemBuilder: (context, index) {
            final item = _subjects[index];
            final subjectName = item["subject"] as String;
            final absentDays = item["absentDays"] as int;
            final remainingDays = item["remainingDays"] as int;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Text(
                  subjectName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Absent Days: $absentDays'),
                    Text('Remaining Days: $remainingDays'),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
