import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/api_service.dart';
import '../services/offline_mode_service.dart';
import '../providers/auth_provider.dart';
import 'package:intl/intl.dart';

class QRScannerScreen extends StatefulWidget {
  final bool isTeacher;
  final String? preSelectedCourseId; // Optional pre-selected course

  const QRScannerScreen({
    Key? key,
    required this.isTeacher,
    this.preSelectedCourseId,
  }) : super(key: key);

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final ApiService _apiService = ApiService();

  // Teacher specific variables
  String? selectedCourseId;
  String? selectedCourseName;
  DateTime? startTime;
  DateTime? endTime;
  bool isCreatingLecture = false;
  Map<String, dynamic>? createdLectureData;

  // Student specific variables
  MobileScannerController? cameraController;
  String? scannedData;
  bool isProcessing = false;
  final OfflineModeService _offlineService = OfflineModeService();

  // Course list - static as per your requirement
  final List<Map<String, dynamic>> courses = [
    {'id': '1', 'name': 'Introduction to Programming', 'table_name': 'programming_lecture'},
    {'id': '2', 'name': 'Data Structures & Algorithms', 'table_name': 'data_structures_lecture'},
    {'id': '3', 'name': 'Database Management Systems', 'table_name': 'database_lecture2'},
    {'id': '4', 'name': 'Computer Networks', 'table_name': 'networks_lecture'},
    {'id': '5', 'name': 'Operating Systems', 'table_name': 'os_lecture'},
    {'id': '6', 'name': 'Software Engineering', 'table_name': 'software_eng_lecture'},
    {'id': '7', 'name': 'Web Development', 'table_name': 'web_dev_lecture'},
    {'id': '8', 'name': 'Mobile Application Development', 'table_name': 'mobile_dev_lecture'},
  ];

  @override
  void initState() {
    super.initState();
    if (!widget.isTeacher) {
      cameraController = MobileScannerController();
    }
    // Set pre-selected course if provided
    if (widget.preSelectedCourseId != null) {
      selectedCourseId = widget.preSelectedCourseId;
      selectedCourseName = courses.firstWhere(
            (c) => c['id'] == widget.preSelectedCourseId,
        orElse: () => {'table_name': 'lecture'},
      )['table_name'];
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.isTeacher ? 'Create Lecture' : 'Scan QR Code for Attendance'),
            centerTitle: false,
            actions: widget.isTeacher ? null : [
              IconButton(
                icon: ValueListenableBuilder(
                  valueListenable: cameraController!.torchState,
                  builder: (context, state, child) {
                    switch (state) {
                      case TorchState.off:
                        return const Icon(Icons.flash_off, color: Colors.grey);
                      case TorchState.on:
                        return const Icon(Icons.flash_on, color: Colors.yellow);
                    }
                  },
                ),
                iconSize: 28.0,
                onPressed: () => cameraController!.toggleTorch(),
              ),
              IconButton(
                icon: ValueListenableBuilder(
                  valueListenable: cameraController!.cameraFacingState,
                  builder: (context, state, child) {
                    switch (state) {
                      case CameraFacing.front:
                        return const Icon(Icons.camera_front);
                      case CameraFacing.back:
                        return const Icon(Icons.camera_rear);
                    }
                  },
                ),
                iconSize: 28.0,
                onPressed: () => cameraController!.switchCamera(),
              ),
            ],
          ),
          body: widget.isTeacher ? _buildTeacherView() : _buildStudentView(authProvider),
        );
      },
    );
  }

  // Teacher View - Create Lecture and Generate QR
  Widget _buildTeacherView() {
    if (createdLectureData != null) {
      return _buildQRDisplayView();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.qr_code_2,
                  size: 48,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create New Lecture',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Select course and time to generate attendance QR code',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Course Selection
          const Text(
            'Select Course',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedCourseId,
                hint: const Text('Choose a course'),
                items: courses.map((course) {
                  return DropdownMenuItem<String>(
                    value: course['id'],
                    child: Text(course['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCourseId = value;
                    selectedCourseName = courses.firstWhere((c) => c['id'] == value)['table_name'];
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Start Time Selection
          const Text(
            'Start Time',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectDateTime(true),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.grey),
                  const SizedBox(width: 12),
                  Text(
                    startTime != null
                        ? DateFormat('yyyy-MM-dd HH:mm').format(startTime!)
                        : 'Select start time',
                    style: TextStyle(
                      fontSize: 16,
                      color: startTime != null ? Colors.black87 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // End Time Selection
          const Text(
            'End Time',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectDateTime(false),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.grey),
                  const SizedBox(width: 12),
                  Text(
                    endTime != null
                        ? DateFormat('yyyy-MM-dd HH:mm').format(endTime!)
                        : 'Select end time',
                    style: TextStyle(
                      fontSize: 16,
                      color: endTime != null ? Colors.black87 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Create Lecture Button
          ElevatedButton(
            onPressed: (selectedCourseId != null && startTime != null && endTime != null && !isCreatingLecture)
                ? _createLecture
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isCreatingLecture
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : const Text(
              'Create Lecture',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // QR Code Display View
  Widget _buildQRDisplayView() {
    final lectureId = createdLectureData!['data']['id'].toString();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Lecture Created Successfully!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // QR Code
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: QrImageView(
                      data: lectureId,
                      version: QrVersions.auto,
                      size: 250.0,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Lecture Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Lecture ID: $lectureId',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          courses.firstWhere((c) => c['id'] == selectedCourseId)['name'],
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${DateFormat('HH:mm').format(startTime!)} - ${DateFormat('HH:mm').format(endTime!)}',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              createdLectureData = null;
                              selectedCourseId = null;
                              selectedCourseName = null;
                              startTime = null;
                              endTime = null;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(12),
                          ),
                          child: const Text('Create Another'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(12),
                          ),
                          child: const Text('Done'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Student View - QR Scanner
  Widget _buildStudentView(AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // Instructions
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
          ),
          child: Column(
            children: [
              Icon(
                Icons.qr_code_scanner,
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                'Point camera at the lecture QR Code',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                'Make sure the QR Code is clearly visible in the designated area',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // QR Scanner
        Expanded(
          flex: 5,
          child: Stack(
            children: [
              MobileScanner(
                controller: cameraController,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    if (!isProcessing && barcode.rawValue != null) {
                      _processStudentQRCode(barcode.rawValue!, authProvider);
                      break;
                    }
                  }
                },
              ),

              // Overlay
              Center(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 4,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      // Corner decorations
                      Positioned(
                        top: -2,
                        left: -2,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -2,
                        left: -2,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (isProcessing)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Marking attendance...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Please wait',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Status and controls
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              if (scannedData != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Lecture ID Scanned:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        scannedData!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Help text
              const Text(
                'Use flash and camera switch buttons above',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Date/Time Picker
  Future<void> _selectDateTime(bool isStart) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          final dateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );

          if (isStart) {
            startTime = dateTime;
          } else {
            endTime = dateTime;
          }
        });
      }
    }
  }

  // Create Lecture (Teacher)
  Future<void> _createLecture() async {
    setState(() {
      isCreatingLecture = true;
    });

    try {
      final teacherId = await _apiService.getUserId();
      final lectureNumber = DateTime.now().millisecondsSinceEpoch % 1000; // Generate unique number

      final response = await _apiService.createLecture({
        'teacher_id': int.parse(teacherId ?? '2'),
        'course_id': int.parse(selectedCourseId!),
        'table_name': '${selectedCourseName}_$lectureNumber',
        'start_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(startTime!),
        'end_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(endTime!),
      });

      if (response['success']) {
        setState(() {
          createdLectureData = response['data'];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Lecture created successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } else {
        throw Exception(response['message'] ?? 'Failed to create lecture');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } finally {
      setState(() {
        isCreatingLecture = false;
      });
    }
  }

  // Process QR Code (Student)
  Future<void> _processStudentQRCode(String lectureId, AuthProvider authProvider) async {
    if (isProcessing) return;

    setState(() {
      isProcessing = true;
      scannedData = lectureId;
    });

    try {
      // Get student ID from stored data
      final studentId = await _apiService.getUserId();

      // Assuming we need to determine course_id from lecture_id
      // In real scenario, you might need to fetch lecture details first
      final attendanceData = {
        'course_id': 1, // You might need to get this from lecture details
        'lecture_id': 1,
        'student_id': int.parse('2'),
        'present': true,
      };

      final result = await _apiService.markStudentAttendance(lectureId, attendanceData);

      if (result['success']) {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Attendance marked successfully!',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        );

        // Show success dialog
        _showResultDialog(
          'Attendance Marked Successfully! ✅',
          'Your attendance has been recorded successfully\n\nThank you for attending!',
          Colors.green,
          Icons.check_circle_outline,
        );
      } else {
        // Failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to mark attendance'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

        _showResultDialog(
          'Failed to Mark Attendance ❌',
          result['message'] ?? 'Error marking attendance.\nPlease check the QR Code and try again.',
          Colors.red,
          Icons.error_outline,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Connection error. Please check your internet.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

      _showResultDialog(
        'Connection Error 📱',
        'Unable to connect to server.\nPlease check your internet connection and try again.',
        Colors.orange,
        Icons.wifi_off,
      );
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  void _showResultDialog(String title, String message, Color color, IconData icon) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        actions: [
          if (color == Colors.red || color == Colors.orange)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  scannedData = null;
                });
              },
              child: Text(
                'Try Again',
                style: TextStyle(color: color),
              ),
            ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // Go back to home screen
            },
            child: const Text(
              'Back to Home',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}