import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../services/offline_mode_service.dart';
import 'absence_screen.dart';
import 'attendance_history_screen.dart';
import 'chat_screen.dart';
import 'payment_screen.dart';
import 'grades_screen.dart';
import 'qr_scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final ApiService _apiService = ApiService();
  final OfflineModeService _offlineService = OfflineModeService();

  // Doctor-specific: QR Code generation
  bool _lectureCreated = false;
  bool _isGeneratingQR = false;
  String? _qrData;
  String? _courseId = "1"; // Default course ID

  // Lecture info
  final TextEditingController _lectureNameController = TextEditingController();
  final TextEditingController _lectureSpecialtyController = TextEditingController();
  String _selectedYear = '1';
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _lectureNameController.dispose();
    _lectureSpecialtyController.dispose();
    super.dispose();
  }

  Future<void> _generateQRCode() async {
    setState(() {
      _isGeneratingQR = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      Map<String, dynamic> result;

      if (authProvider.isOfflineMode) {
        // Use offline service
        result = await _offlineService.generateQRCode(_courseId!);
      } else {
        // Try API first, fallback to offline
        try {
          result = await _apiService.generateQRCode(_courseId!);
        } catch (e) {
          print('API failed, using offline mode: $e');
          result = await _offlineService.generateQRCode(_courseId!);
        }
      }

      if (result['success']) {
        setState(() {
          _qrData = result['data']['qr_data'];
          _lectureCreated = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.isOfflineMode
                ? 'تم إنشاء QR Code بنجاح (وضع محلي)'
                : 'تم إنشاء QR Code بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'فشل في إنشاء QR Code'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isGeneratingQR = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isLoggedIn) {
          return const Scaffold(
            body: Center(child: Text('غير مسجل دخول')),
          );
        }

        final user = authProvider.currentUser!;
        final isStudent = user.role == 'student';

        final List<BottomNavigationBarItem> bottomItems = isStudent
            ? [
          const BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Attendance',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.attach_money_outlined),
            label: 'Fees',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            label: 'Chat',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            label: 'Grades',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_sharp),
            label: 'Absence',
          ),
        ]
            : [
          const BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'Generate QR',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            label: 'Chat',
          ),
        ];

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Text('أهلاً، ${user.name}'),
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
                  //       Icon(Icons.wifi_off, size: 14, color: Colors.white),
                  //       SizedBox(width: 4),
                  //       Text(
                  //         'وضع محلي',
                  //         style: TextStyle(fontSize: 12, color: Colors.white),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ],
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('تسجيل الخروج'),
                      content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('إلغاء'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await authProvider.logout();
                          },
                          child: const Text('تسجيل الخروج'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          body: _buildBody(isStudent),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            unselectedItemColor: Colors.grey,
            selectedItemColor: Theme.of(context).primaryColor,
            type: BottomNavigationBarType.fixed,
            items: bottomItems,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildBody(bool isStudent) {
    if (isStudent) {
      switch (_currentIndex) {
        case 0:
          return _buildStudentAttendanceTab();
        case 1:
          return PaymentScreen();
        case 2:
          return OneSidedChatScreen(userType: 'student');
        case 3:
          return GradesScreen();
        case 4:
          return AbsenceScreen();
        default:
          return const Center(child: Text('صفحة غير معروفة'));
      }
    } else {
      switch (_currentIndex) {
        case 0:
          return _buildTeacherQRTab();
        case 1:
          return AttendanceHistoryScreen();
        case 2:
          return OneSidedChatScreen(userType: 'teacher');
        default:
          return const Center(child: Text('صفحة غير معروفة'));
      }
    }
  }

  // Student Attendance Tab - QR Scanner
  Widget _buildStudentAttendanceTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.qr_code_scanner,
            size: 100,
            color: Colors.blue,
          ),
          const SizedBox(height: 24),
          const Text(
            'مسح QR Code للحضور',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'اضغط على الزر لمسح QR Code وتسجيل الحضور',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('مسح QR Code'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QRScannerScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Teacher QR Generation Tab
  Widget _buildTeacherQRTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'إدارة الحضور',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 30),

            if (!_lectureCreated) ...[
              const Icon(
                Icons.qr_code,
                size: 100,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'إنشاء محاضرة جديدة',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'اضغط على الزر لإنشاء QR Code للمحاضرة',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: _isGeneratingQR
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Icon(Icons.add),
                label: Text(_isGeneratingQR ? 'جاري الإنشاء...' : 'إنشاء محاضرة'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                onPressed: _isGeneratingQR ? null : _showCreateLectureSheet,
              ),
            ] else ...[
              // Show QR Code
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    const Text(
                      'QR Code للحضور',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (_qrData != null)
                      QrImageView(
                        data: _qrData!,
                        version: QrVersions.auto,
                        size: 250.0,
                      )
                    else
                      Container(
                        height: 250,
                        width: 250,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text('QR CODE'),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _endLecture,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('إنهاء المحاضرة'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCreateLectureSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                top: 16,
                left: 16,
                right: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'إنشاء محاضرة جديدة',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _lectureNameController,
                      decoration: const InputDecoration(
                        hintText: 'اسم المحاضرة',
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: ctx,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setModalState(() {
                            _selectedTime = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time),
                            const SizedBox(width: 8),
                            Text(
                              _selectedTime == null
                                  ? 'اختر وقت انتهاء المحاضرة'
                                  : _selectedTime!.format(ctx),
                              style: TextStyle(
                                color: _selectedTime == null
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedYear,
                      items: const [
                        DropdownMenuItem(value: '1', child: Text('السنة الأولى')),
                        DropdownMenuItem(value: '2', child: Text('السنة الثانية')),
                        DropdownMenuItem(value: '3', child: Text('السنة الثالثة')),
                        DropdownMenuItem(value: '4', child: Text('السنة الرابعة')),
                      ],
                      onChanged: (val) {
                        setModalState(() {
                          _selectedYear = val ?? '1';
                        });
                      },
                      decoration: const InputDecoration(
                        filled: true,
                        hintText: 'اختر السنة',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _lectureSpecialtyController,
                      decoration: const InputDecoration(
                        hintText: 'التخصص',
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _generateQRCode();
                      },
                      child: const Text('إنشاء QR Code'),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _endLecture() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إنهاء المحاضرة'),
        content: const Text('هل أنت متأكد من إنهاء المحاضرة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _lectureCreated = false;
                _qrData = null;
                _lectureNameController.clear();
                _lectureSpecialtyController.clear();
                _selectedTime = null;
                _selectedYear = '1';
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إنهاء المحاضرة بنجاح'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('إنهاء'),
          ),
        ],
      ),
    );
  }
}