import 'package:flutter/material.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // بيانات تجريبية: قائمة محاضرات، ولكل محاضرة تاريخ ولائحة بالطلبة الحاضرين
    final List<Map<String, dynamic>> lectures = [
      {
        "title": "Math Lecture",
        "date": "Monday, Feb 13, 2025",
        "attendees": [
          {"name": "Ahmed Mohamed", "id": "1001"},
          {"name": "Khaled Ibrahim", "id": "1002"},
          {"name": "Sarah Ali", "id": "1003"},
        ]
      },
      {
        "title": "Physics Lecture",
        "date": "Tuesday, Feb 14, 2025",
        "attendees": [
          {"name": "Mona Hassan", "id": "1010"},
          {"name": "Hager Ali", "id": "1011"},
        ]
      },
      {
        "title": "Chemistry Lecture",
        "date": "Wednesday, Feb 15, 2025",
        "attendees": [
          {"name": "Omar Tarek", "id": "1015"},
          {"name": "Reham Gamal", "id": "1016"},
          {"name": "Aisha Youssef", "id": "1017"},
        ]
      },
      {
        "title": "Biology Lecture",
        "date": "Thursday, Feb 16, 2025",
        "attendees": [
          {"name": "Mustafa Khaled", "id": "1020"},
          {"name": "Nour Ahmed", "id": "1021"},
        ]
      },
    ];

    return Container(
      height: 600,
      child: Scaffold(

        body: ListView.separated(
          itemCount: lectures.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final lecture = lectures[index];
            return ListTile(
              title: Text(lecture["title"]),
              subtitle: Text(lecture["date"]),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // عرض الـ BottomSheet لعرض الطلبة
                _showAttendeesBottomSheet(
                  context,
                  lecture["title"],
                  lecture["attendees"],
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// دالة لعرض BottomSheet عند الضغط على محاضرة معيّنة
  void _showAttendeesBottomSheet(
      BuildContext context,
      String lectureTitle,
      List<Map<String, String>> attendees,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // يسمح للـ BottomSheet بالتمدد
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            top: 12,
            // لإزاحة الـ BottomSheet عند ظهور الكيبورد (لو تضمن حقول نصية)
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // عنوان المحاضرة
              Text(
                lectureTitle,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 12),

              // إذا لا يوجد طلبة
              if (attendees.isEmpty)
                const Text(
                  'No attendees for this lecture',
                  style: TextStyle(color: Colors.grey),
                )
              else
              // قائمة الطلبة الحاضرين
                SizedBox(
                  // حدد ارتفاعًا أقصى حتى لا تملأ الشاشة بأكملها
                  height: 300,
                  child: ListView.builder(
                    itemCount: attendees.length,
                    itemBuilder: (context, i) {
                      final student = attendees[i];
                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(student["name"] ?? ""),
                        subtitle: Text("ID: ${student["id"]}"),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),

              // زر لإغلاق BottomSheet
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 16, vertical: 8
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(

                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
