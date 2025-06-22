import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../services/offline_mode_service.dart';
import '../models/models.dart';
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
  bool _isGeneratingQR = false;
  String? _qrData;
  String? _selectedCourseId;
  String? _selectedSessionId;
  List<Course> _courses = [];
  List<Session> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isTeacher) {
      try {
        Map<String, dynamic> result;
        if (authProvider.isOfflineMode) {
          // Mock data for offline mode
          setState(() {
            _courses = [
              Course(id: '1', name: 'Flutter Development', code: 'CS101'),
              Course(id: '2', name: 'Database Systems', code: 'CS201'),
            ];
          });
        } else {
          result = await _apiService.getTeacherCourses();
          if (result['success']) {
            setState(() {
              _courses = (result['data']['courses'] as List)
                  .map((c) => Course.fromJson(c))
                  .toList();
            });
          }
        }
      } catch (e) {
        print('Error loading courses: $e');
      }
    }
  }

  Future<void> _loadSessions(String courseId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      Map<String, dynamic> result;
      if (authProvider.isOfflineMode) {
        result = await _offlineService.getCourseSessions(courseId);
      } else {
        result = await _apiService.getCourseSessions(courseId);
      }

      if (result['success']) {
        setState(() {
          _sessions = (result['data']['sessions'] as List)
              .map((s) => Session.fromJson(s))
              .toList();
        });
      }
    } catch (e) {
      print('Error loading sessions: $e');
    }
  }

  Future<void> _generateQRCode() async {
    if (_selectedCourseId == null || _selectedSessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select course and session'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isGeneratingQR = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      Map<String, dynamic> result;

      if (authProvider.isOfflineMode) {
        result = await _offlineService.generateQRCode(_selectedCourseId!);
      } else {
        result = await _apiService.generateQRCode(_selectedCourseId!, _selectedSessionId!);
      }

      if (result['success']) {
        setState(() {
          _qrData = result['data']['qr_code'];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR Code generated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to generate QR Code'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
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
            body: Center(child: Text('Not logged in')),
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
            title: Text('Welcome, ${user.name}'),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await authProvider.logout();
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/choose_role',
                                  (route) => false,
                            );
                          },
                          child: const Text('Logout'),
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
          return _buildStudentAttendanceTab(isStudent);
        case 1:
          return PaymentScreen();
        case 2:
          return OneSidedChatScreen(userType: 'student');
        case 3:
          return GradesScreen();
        case 4:
          return AbsenceScreen();
        default:
          return const Center(child: Text('Unknown page'));
      }
    } else {
      switch (_currentIndex) {
        case 0:
          return QRScannerScreen( isTeacher:true,);
        case 1:
          return AttendanceHistoryScreen();
        case 2:
          return OneSidedChatScreen(userType: 'teacher');
        default:
          return const Center(child: Text('Unknown page'));
      }
    }
  }

  // Student Attendance Tab - QR Scanner
  Widget _buildStudentAttendanceTab(bool isStudent) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.qr_code_scanner,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'Scan QR Code for Attendance',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              child: const Text(
                'Press the button to scan QR code and mark attendance',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan QR Code'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QRScannerScreen( isTeacher: isStudent==true?false:true,),
                  ),
                );
              },
            ),
          ],
        ),
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
              'Attendance Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 30),

            // Course Selection
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Course',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCourseId,
                    hint: const Text('Choose a course'),
                    items: _courses.map((course) {
                      return DropdownMenuItem(
                        value: course.id,
                        child: Text('${course.name} (${course.code})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCourseId = value;
                        _selectedSessionId = null;
                        _sessions = [];
                        _qrData = null;
                      });
                      if (value != null) {
                        _loadSessions(value);
                      }
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Session Selection
            if (_selectedCourseId != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Session',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedSessionId,
                      hint: const Text('Choose a session'),
                      items: _sessions.map((session) {
                        return DropdownMenuItem(
                          value: session.id,
                          child: Text(session.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSessionId = value;
                          _qrData = null;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Generate QR Button
            if (_selectedCourseId != null && _selectedSessionId != null && _qrData == null)
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
                    : const Icon(Icons.qr_code),
                label: Text(_isGeneratingQR ? 'Generating...' : 'Generate QR Code'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                onPressed: _isGeneratingQR ? null : _generateQRCode,
              ),

            // Show QR Code
            if (_qrData != null) ...[
              const SizedBox(height: 24),
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
                      'QR Code for Attendance',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    QrImageView(
                      data: _qrData!,
                      version: QrVersions.auto,
                      size: 250.0,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Students can scan this code to mark attendance',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _qrData = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Clear QR Code'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}