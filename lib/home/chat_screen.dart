import 'package:flutter/material.dart';

class OneSidedChatScreen extends StatefulWidget {
  static const String routeName = '/one_sided_chat';

  final String userType; // "doctor" or "student"

  const OneSidedChatScreen({
    Key? key,
    required this.userType,
  }) : super(key: key);

  @override
  State<OneSidedChatScreen> createState() => _OneSidedChatScreenState();
}

class _OneSidedChatScreenState extends State<OneSidedChatScreen> {
  // يتحكم في حقل كتابة الرسالة للطبيب
  final TextEditingController _messageController = TextEditingController();

  // قائمة رسائل بسيطة، جميعها من "الطبيب"
  // وسنظهرها بلون أزرق، ومحاذاة واحدة
  List<String> messages = [
    "Hello, welcome to the lecture updates!",
    "I will post extra materials here.",
    "If you have any questions, let me know.",
    "Assignment 2 is due next Monday.",
    "Good luck studying!"
  ];

  @override
  Widget build(BuildContext context) {
    // هل هو طبيب أم طالب؟
    final bool isDoctor = (widget.userType == 'student');

    // لون الفقاعة
    const Color bubbleColor = Color(0xFF2D336B); // أزرق داكن
    // لون خلفية الصفحة
    const Color backgroundColor = Color(0xFFF9F9F9);

    return Container(
      height: 649,
      child: Scaffold(
        backgroundColor: backgroundColor,

        body: Column(
          children: [
            // عرض الرسائل
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final text = messages[index];
                  return _buildChatBubble(text, bubbleColor);
                },
              ),
            ),

            // إذا كان طبيب، نعرض له حقل الكتابة. إذا طالب، لا يظهر شيء.
            if (!isDoctor) _buildMessageInput(bubbleColor),
          ],
        ),
      ),
    );
  }

  /// عنصر واجهة الفقاعة الواحدة. جميعها بلون واحد، ومحاذاة لليسار (مثلاً).
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
        // عرض أقصى للفقاعة (حتى لا تتمدّد بعرض الشاشة كلها)
        constraints: const BoxConstraints(maxWidth: 250),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  /// حقل إدخال الرسالة للطبيب مع زر إرسال
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
          // حقل النص
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
          // زر الإرسال
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

  /// إرسال الرسالة (يضيفها لقائمة messages)
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
