import 'package:cmp/home/chat_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';


  const HomeScreen({
    Key? key,
   }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Doctor-specific: Has the doctor created the lecture?
  bool _lectureCreated = false;
  String? userType; // 'student' or 'teacher' ...الخ

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is String) {
      userType = args;
    }
  }
  // List of students who actually attended (dummy)
  final List<Map<String, String>> _attendedStudents = [];

  // A full list of students (dummy)
  final List<Map<String, String>> _allStudents = [
    {"name": "Ahmed Mohamed", "code": "1001"},
    {"name": "Khaled Ibrahim", "code": "1002"},
    {"name": "Sarah Ali", "code": "1003"},
    {"name": "Mahmoud Hassan", "code": "1004"},
    {"name": "Reham Gamal", "code": "1005"},
    {"name": "Abdullah Ahmed", "code": "1006"},
    {"name": "Aisha Yousef", "code": "1007"},
    {"name": "Tarek Omar", "code": "1008"},
    {"name": "Lubna Ibrahim", "code": "1009"},
    {"name": "Hager Mahmoud", "code": "1010"},
  ];

  // Lecture info (for doctor)
  final TextEditingController _lectureNameController = TextEditingController();
  final TextEditingController _lectureSpecialtyController = TextEditingController();
  String _selectedYear = '1';
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    final String userLabel = userType == 'student' ? 'Student' : 'Doctor';

    // Bottom nav items
    final List<BottomNavigationBarItem> bottomItems =
    userType == 'student'
        ? [
      const BottomNavigationBarItem(
        icon: Icon(Icons.checklist_rounded),
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
    ]
        : [
      const BottomNavigationBarItem(
        icon: Icon(Icons.checklist_rounded),
        label: 'Attendance',
      ),  const BottomNavigationBarItem(
        icon: Icon(Icons.history),
        label: 'history',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.chat_outlined),
        label: 'Chat',
      ),

    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, $userLabel'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildBody(),
        ],
      ), // We'll decide content based on _currentIndex
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: bottomItems,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  /// This method decides which page to show based on the current tab.
  Widget _buildBody() {
     switch (_currentIndex) {
      case 0:
      // ATTENDANCE PAGE => show attendance UI + button for Student OR Doctor
        return _buildAttendanceTab();
      case 1:
        return const Center(child: Text('Chat Page'));
      case 2: // Only Student has 3rd tab (Fees)
        return   OneSidedChatScreen(userType:userType ??'',);
        // return const Center(child: Text('Fees Page'));
      default:
        return const Center(child: Text('Unknown Page'));
    }
  }

  /// Attendance tab content
  Widget _buildAttendanceTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Example text
            Text(
              'Attendance Page - ${userType == 'student' ? 'Student' : 'Doctor'}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Show the relevant button/section based on userType
            if (userType == 'student')
              _buildStudentAttendance()
            else
              Center(child: Column(
                children: [
                  SizedBox(
                    height: 00,
                  ),
                  _buildDoctorAttendance(),
                ],
              )),
          ],
        ),
      ),
    );
  }

  /// STUDENT: shows a button to Scan QR
  Widget _buildStudentAttendance() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.qr_code_scanner_outlined),
      label: const Text('Scan QR'),
      onPressed: () {
        // Show message for now
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance recorded successfully!'),
          ),
        );
      },
    );
  }

  /// DOCTOR: If lecture not created => button to create
  /// If lecture created => show big QR code + End Lecture
  Widget _buildDoctorAttendance() {
    if (!_lectureCreated) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Create Attendance Lecture'),
        onPressed: _showCreateLectureSheet,
      );
    } else {
      return Column(
        children: [
          const SizedBox(height: 16),
          Container(
            height: 400,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'QR CODE HERE',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _showEndLectureSheet,
            child: const Text('End Lecture'),
          ),
        ],
      );
    }
  }

  /// BottomSheet to create the lecture
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
                top: 16, left: 16, right: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Create Attendance Lecture',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _lectureNameController,
                      decoration: const InputDecoration(
                        hintText: 'Lecture Name',
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
                                  ? 'Select End Time'
                                  : _selectedTime!.format(ctx),
                              style: TextStyle(
                                color:
                                _selectedTime == null ? Colors.grey : Colors.black,
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
                        DropdownMenuItem(value: '1', child: Text('Year 1')),
                        DropdownMenuItem(value: '2', child: Text('Year 2')),
                        DropdownMenuItem(value: '3', child: Text('Year 3')),
                        DropdownMenuItem(value: '4', child: Text('Year 4')),
                      ],
                      onChanged: (val) {
                        setModalState(() {
                          _selectedYear = val ?? '1';
                        });
                      },
                      decoration: const InputDecoration(
                        filled: true,
                        hintText: 'Select Year',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _lectureSpecialtyController,
                      decoration: const InputDecoration(
                        hintText: 'Specialty',
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _lectureCreated = true;
                        });
                      },
                      child: const Text('Done'),
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

  /// BottomSheet for ending the lecture -> see the list of attended students
  void _showEndLectureSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 16, left: 16, right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Attended Students',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (_attendedStudents.isEmpty)
                const Text(
                  'No students yet.',
                  style: TextStyle(color: Colors.grey),
                )
              else
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: _attendedStudents.length,
                    itemBuilder: (ctx, i) {
                      final s = _attendedStudents[i];
                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(s['name'] ?? ''),
                        subtitle: Text('Code: ${s['code']}'),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _showAddStudentSheet,
                      child: const Text('Add Student'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Reset
                        setState(() {
                          _lectureCreated = false;
                          _attendedStudents.clear();
                          _lectureNameController.clear();
                          _lectureSpecialtyController.clear();
                          _selectedTime = null;
                          _selectedYear = '1';
                        });
                      },
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  /// BottomSheet to add a student from a dummy list
  void _showAddStudentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                top: 16, left: 16, right: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select a Student',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: _allStudents.length,
                      itemBuilder: (context, index) {
                        final std = _allStudents[index];
                        return ListTile(
                          onTap: () {
                            // Add if not already in the list
                            if (!_attendedStudents.any((s) => s['code'] == std['code'])) {
                              setState(() {
                                _attendedStudents.add(std);
                              });
                            }
                            Navigator.pop(ctx);
                          },
                          title: Text(std['name'] ?? ''),
                          subtitle: Text('Code: ${std['code']}'),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
