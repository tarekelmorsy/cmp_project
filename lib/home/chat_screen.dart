import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../services/offline_mode_service.dart';
import '../models/models.dart';

class OneSidedChatScreen extends StatelessWidget {
  static const String routeName = '/one_sided_chat';

  final String userType;
  const OneSidedChatScreen({Key? key, required this.userType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (userType == 'student') {
      return _StudentChatScreen();
    } else {
      return _DoctorYearSelectionScreen();
    }
  }
}

/// شاشة الشات للطالب - يشاهد الرسائل فقط
class _StudentChatScreen extends StatefulWidget {
  @override
  State<_StudentChatScreen> createState() => _StudentChatScreenState();
}

class _StudentChatScreenState extends State<_StudentChatScreen> {
  final ApiService _apiService = ApiService();
  final OfflineModeService _offlineService = OfflineModeService();
  List<ChatMessage> messages = [];
  bool isLoading = true;
  String? errorMessage;
  String courseId = "1"; // Default course ID

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      Map<String, dynamic> result;

      if (authProvider.isOfflineMode) {
        // Use offline service
        result = await _offlineService.getChatMessages(courseId);
      } else {
        // Try API first, fallback to offline
        try {
          result = await _apiService.getChatMessages(courseId);
        } catch (e) {
          print('API failed, using offline mode: $e');
          result = await _offlineService.getChatMessages(courseId);
        }
      }

      if (result['success']) {
        final List<dynamic> messagesData = result['data']['messages'] ?? [];
        setState(() {
          messages = messagesData.map((msg) => ChatMessage.fromJson(msg)).toList();
        });
      } else {
        setState(() {
          errorMessage = result['message'] ?? 'فشل في تحميل الرسائل';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'خطأ في تحميل الرسائل: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bubbleColor = Color(0xFF2D336B);
    const Color backgroundColor = Color(0xFFF9F9F9);

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SizedBox(
          height: 649,
          child: Scaffold(
            backgroundColor: backgroundColor,
            body: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.chat, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text(
                        'إعلانات المادة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (authProvider.isOfflineMode) ...[
                        const SizedBox(width: 8),
                        // Container(
                        //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        //   decoration: BoxDecoration(
                        //     color: Colors.orange,
                        //     borderRadius: BorderRadius.circular(12),
                        //   ),
                        //   child: const Row(
                        //     mainAxisSize: MainAxisSize.min,
                        //     children: [
                        //       Icon(Icons.wifi_off, size: 12, color: Colors.white),
                        //       SizedBox(width: 4),
                        //       Text(
                        //         'محلي',
                        //         style: TextStyle(fontSize: 10, color: Colors.white),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: _loadMessages,
                      ),
                    ],
                  ),
                ),

                // Messages
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : errorMessage != null
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          authProvider.isOfflineMode ? Icons.wifi_off : Icons.error,
                          size: 60,
                          color: authProvider.isOfflineMode ? Colors.orange : Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          authProvider.isOfflineMode
                              ? 'يتم تشغيل التطبيق في الوضع المحلي'
                              : errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: authProvider.isOfflineMode ? Colors.orange : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadMessages,
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  )
                      : messages.isEmpty
                      ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'لا توجد رسائل بعد',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return _buildChatBubble(message, bubbleColor);
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

  Widget _buildChatBubble(ChatMessage message, Color color) {
    return Container(
      alignment: Alignment.centerRight,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
        ),
        constraints: const BoxConstraints(maxWidth: 280),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inDays > 0) {
      return '${diff.inDays} يوم';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} ساعة';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}

/// شاشة اختيار السنة للدكتور
class _DoctorYearSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFFF9F9F9);

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          height: 649,
          child: Scaffold(
            backgroundColor: backgroundColor,
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'اختر السنة الدراسية للدردشة معها',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (authProvider.isOfflineMode) ...[
                          const SizedBox(width: 8),
                          // Container(
                          //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          //   decoration: BoxDecoration(
                          //     color: Colors.orange,
                          //     borderRadius: BorderRadius.circular(12),
                          //   ),
                          //   child: const Row(
                          //     mainAxisSize: MainAxisSize.min,
                          //     children: [
                          //       Icon(Icons.wifi_off, size: 12, color: Colors.white),
                          //       SizedBox(width: 4),
                          //       Text(
                          //         'محلي',
                          //         style: TextStyle(fontSize: 10, color: Colors.white),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Year buttons
                  _buildYearButton(context, 1),
                  const SizedBox(height: 16),
                  _buildYearButton(context, 2),
                  const SizedBox(height: 16),
                  _buildYearButton(context, 3),
                  const SizedBox(height: 16),
                  _buildYearButton(context, 4),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildYearButton(BuildContext context, int year) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DoctorChatScreen(year: year),
            ),
          );
        },
        child: Text(
          'السنة ${_getYearName(year)}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String _getYearName(int year) {
    switch (year) {
      case 1: return 'الأولى';
      case 2: return 'الثانية';
      case 3: return 'الثالثة';
      case 4: return 'الرابعة';
      default: return '$year';
    }
  }
}

/// شاشة دردشة الدكتور لسنة محددة
class DoctorChatScreen extends StatefulWidget {
  final int year;
  const DoctorChatScreen({Key? key, required this.year}) : super(key: key);

  @override
  State<DoctorChatScreen> createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ApiService _apiService = ApiService();
  final OfflineModeService _offlineService = OfflineModeService();
  List<ChatMessage> messages = [];
  bool isLoading = true;
  bool isSending = false;
  String? errorMessage;
  String courseId = "1"; // Default course ID

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      Map<String, dynamic> result;

      if (authProvider.isOfflineMode) {
        // Use offline service
        result = await _offlineService.getChatMessages(courseId);
      } else {
        // Try API first, fallback to offline
        try {
          result = await _apiService.getChatMessages(courseId);
        } catch (e) {
          print('API failed, using offline mode: $e');
          result = await _offlineService.getChatMessages(courseId);
        }
      }

      if (result['success']) {
        final List<dynamic> messagesData = result['data']['messages'] ?? [];
        setState(() {
          messages = messagesData.map((msg) => ChatMessage.fromJson(msg)).toList();
        });
      } else {
        setState(() {
          errorMessage = result['message'] ?? 'فشل في تحميل الرسائل';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'خطأ في تحميل الرسائل: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || isSending) return;

    setState(() {
      isSending = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      Map<String, dynamic> result;

      if (authProvider.isOfflineMode) {
        // Use offline service
        result = await _offlineService.sendChatMessage(courseId, text);
      } else {
        // Try API first, fallback to offline
        try {
          result = await _apiService.sendChatMessage(courseId, text);
        } catch (e) {
          print('API failed, using offline mode: $e');
          result = await _offlineService.sendChatMessage(courseId, text);
        }
      }

      if (result['success']) {
        _messageController.clear();

        // Add message to local list for immediate UI update
        final user = authProvider.currentUser!;
        final newMessage = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          courseId: courseId,
          senderId: user.id,
          senderName: user.name,
          senderRole: user.role,
          message: text,
          timestamp: DateTime.now(),
        );

        setState(() {
          messages.add(newMessage);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.isOfflineMode
                ? 'تم إرسال الرسالة بنجاح (وضع محلي)'
                : 'تم إرسال الرسالة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'فشل في إرسال الرسالة'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في إرسال الرسالة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bubbleColor = Color(0xFF2D336B);
    const Color backgroundColor = Color(0xFFF9F9F9);

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: Row(
              children: [
                Text('دردشة السنة ${_getYearName(widget.year)}'),
                if (authProvider.isOfflineMode) ...[
                  const SizedBox(width: 8),
                  // Container(
                  //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  //   decoration: BoxDecoration(
                  //     color: Colors.orange,
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   child: const Row(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       Icon(Icons.wifi_off, size: 12, color: Colors.white),
                  //       SizedBox(width: 4),
                  //       Text(
                  //         'محلي',
                  //         style: TextStyle(fontSize: 10, color: Colors.white),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ],
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadMessages,
              ),
            ],
          ),
          body: Column(
            children: [
              // Messages
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        authProvider.isOfflineMode ? Icons.wifi_off : Icons.error,
                        size: 60,
                        color: authProvider.isOfflineMode ? Colors.orange : Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        authProvider.isOfflineMode
                            ? 'يتم تشغيل التطبيق في الوضع المحلي'
                            : errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: authProvider.isOfflineMode ? Colors.orange : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMessages,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
                    : messages.isEmpty
                    ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'لا توجد رسائل بعد\nابدأ بكتابة رسالة للطلاب',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _buildChatBubble(message, bubbleColor);
                  },
                ),
              ),

              // Message input
              _buildMessageInput(bubbleColor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatBubble(ChatMessage message, Color color) {
    return Container(
      alignment: Alignment.centerRight,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
        ),
        constraints: const BoxConstraints(maxWidth: 280),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
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
                  hintText: 'اكتب رسالة للطلاب...',
                  border: InputBorder.none,
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: isSending ? null : _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSending ? Colors.grey : color,
                shape: BoxShape.circle,
              ),
              child: isSending
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Icon(Icons.send, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inDays > 0) {
      return '${diff.inDays} يوم';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} ساعة';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  String _getYearName(int year) {
    switch (year) {
      case 1: return 'الأولى';
      case 2: return 'الثانية';
      case 3: return 'الثالثة';
      case 4: return 'الرابعة';
      default: return '$year';
    }
  }
}