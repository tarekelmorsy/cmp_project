import 'package:flutter/material.dart';

/// شاشة رئيسية تتصرف حسب نوع المستخدم.
/// - الطالب (student): يعرض شات جاهز بالرسائل فقط، دون إمكانية إضافة رسائل.
/// - الدكتور (doctor): يعرض أولًا 4 أزرار (سنوات)، وعند اختيار سنة، ينتقل إلى DoctorChatScreen لعرض/إضافة رسائل.
class OneSidedChatScreen extends StatelessWidget {
  static const String routeName = '/one_sided_chat';

  final String userType; // 'doctor' or 'student'
  const OneSidedChatScreen({Key? key, required this.userType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // إذا طالب: انتقل مباشرة لعرض شات الطالب
    if (userType == 'student') {
      return _StudentChatScreen();
    } else {
      // إذا دكتور: عرض اختيار السنة
      return _DoctorYearSelectionScreen();
    }
  }
}

/// ------------------------
/// 1) شاشة الشات للطالب فقط
/// الطالب لا يكتب رسائل؛ مجرد عرض رسائل بلون أزرق
/// ------------------------
class _StudentChatScreen extends StatefulWidget {
  @override
  State<_StudentChatScreen> createState() => _StudentChatScreenState();
}

class _StudentChatScreenState extends State<_StudentChatScreen> {
  // رسائل افتراضية، كلها من الدكتور - تظهر بلون واحد (سنعرضها وكأنها من جهة واحدة)
  // ولكن طالب لا يمكنه الرد
  List<String> messages = [
    "Hello Student, welcome to the announcements!",
    "Please check the new assignment posted.",
    "We have an online lecture next week.",
    "If you have questions, let me know in class!",
  ];

  @override
  Widget build(BuildContext context) {
    const Color bubbleColor = Color(0xFF2D336B); // أزرق داكن
    const Color backgroundColor = Color(0xFFF9F9F9);

    return SizedBox(
      height: 649,
      child: Scaffold(
        backgroundColor: backgroundColor,

        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final text = messages[index];
                  return _buildChatBubble(text, bubbleColor);
                },
              ),
            ),
            // الطالب لا يكتب شيئًا => لا يوجد حقل إدخال
          ],
        ),
      ),
    );
  }

  /// الفقاعة: لون واحد يمين/يسار. هنا سنضبط المحاذاة كيفما نريد (مثل اليسار).
  Widget _buildChatBubble(String text, Color color) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        constraints: const BoxConstraints(maxWidth: 250),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

/// ----------------------------
/// 2) شاشة اختيار السنة للدكتور
/// إذا ضغط Year X => ينتقل إلى DoctorChatScreen(year: X)
/// ----------------------------
class _DoctorYearSelectionScreen extends StatelessWidget {
  const _DoctorYearSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFFF9F9F9);

    return Container(
      height: 649,
      child: Scaffold(
        backgroundColor: backgroundColor,

        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Please choose which year chat you want to open:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),

              // أزرار السنوات الأربع
              _buildYearButton(context, 1),
              const SizedBox(height: 12),
              _buildYearButton(context, 2),
              const SizedBox(height: 12),
              _buildYearButton(context, 3),
              const SizedBox(height: 12),
              _buildYearButton(context, 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYearButton(BuildContext context, int year) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // يفتح شاشة دردشة الدكتور مع تحديد السنة
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DoctorChatScreen(year: year),
            ),
          );
        },
        child: Text('Year $year Chat'),
      ),
    );
  }
}

/// ------------------------------
/// 3) شاشة دردشة الدكتور لسنة محددة
/// يستطيع فيها إرسال رسائل، تظهر بلون أزرق واحد
/// ------------------------------
class DoctorChatScreen extends StatefulWidget {
  final int year; // سنة المحادثة المختارة
  const DoctorChatScreen({Key? key, required this.year}) : super(key: key);

  @override
  State<DoctorChatScreen> createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  // رسائل افتراضية، كلها من الدكتور - يمكن توسيعها حسب السنة
  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    // مثال: وضع رسائل مختلفة حسب السنة
    messages = [
      "Hello Year ${widget.year} students!",
      "This chat is for year ${widget.year} only.",
      "Feel free to check updates here.",
    ];
  }

  @override
  Widget build(BuildContext context) {
    const Color bubbleColor = Color(0xFF2D336B); // أزرق داكن
    const Color backgroundColor = Color(0xFFF9F9F9);

    return Container(
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: Text('Doctor Chat - Year ${widget.year}'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // عرض الرسائل
            Expanded(
              child: ListView.builder(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final text = messages[index];
                  return _buildChatBubble(text, bubbleColor);
                },
              ),
            ),

            // حقل كتابة الرسالة (للدكتور)
            _buildMessageInput(bubbleColor),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(String text, Color color) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        constraints: const BoxConstraints(maxWidth: 250),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMessageInput(Color color) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Write a message...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        messages.add(text);
      });
      _messageController.clear();
    }
  }
}
