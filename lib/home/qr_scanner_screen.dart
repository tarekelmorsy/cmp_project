import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/api_service.dart';
import '../services/offline_mode_service.dart';
import '../providers/auth_provider.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  String? scannedData;
  bool isProcessing = false;
  final ApiService _apiService = ApiService();
  final OfflineModeService _offlineService = OfflineModeService();

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                const Text('مسح QR Code للحضور'),
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
            centerTitle: false,
            actions: [
              IconButton(
                icon: ValueListenableBuilder(
                  valueListenable: cameraController.torchState,
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
                onPressed: () => cameraController.toggleTorch(),
              ),
              IconButton(
                icon: ValueListenableBuilder(
                  valueListenable: cameraController.cameraFacingState,
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
                onPressed: () => cameraController.switchCamera(),
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment:  CrossAxisAlignment.center,
            mainAxisAlignment:  MainAxisAlignment.center,
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
                      'وجّه الكاميرا نحو QR Code الخاص بالمحاضرة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'تأكد من وضوح الـ QR Code في المنطقة المحددة',
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
                            _processQRCode(barcode.rawValue!);
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
                                'جاري تسجيل الحضور...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'برجاء الانتظار',
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
                              'تم مسح QR Code:',
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
                      'استخدم أزرار الفلاش وتبديل الكاميرا في الأعلى',
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
          ),
        );
      },
    );
  }

  Future<void> _processQRCode(String qrData) async {
    if (isProcessing) return;

    setState(() {
      isProcessing = true;
      scannedData = qrData;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      Map<String, dynamic> result;

      if (authProvider.isOfflineMode) {
        // Use offline service
        result = await _offlineService.markAttendance(qrData);
      } else {
        // Try API first, fallback to offline
        try {
          result = await _apiService.markAttendance(qrData);
        } catch (e) {
          print('API failed, using offline mode: $e');
          result = await _offlineService.markAttendance(qrData);
        }
      }

      if (result['success']) {
        // Success
        _showResultDialog(
          'تم تسجيل الحضور بنجاح! ✅',
          authProvider.isOfflineMode
              ? 'تم تسجيل حضورك في المحاضرة بنجاح (وضع محلي)\n\nسيتم مزامنة البيانات عند الاتصال بالإنترنت'
              : 'تم تسجيل حضورك في المحاضرة بنجاح\n\nشكراً لحضورك!',
          Colors.green,
          Icons.check_circle_outline,
        );
      } else {
        // Failed
        _showResultDialog(
          'فشل في تسجيل الحضور ❌',
          result['message'] ?? 'حدث خطأ في تسجيل الحضور.\nتأكد من صحة QR Code وحاول مرة أخرى.',
          Colors.red,
          Icons.error_outline,
        );
      }
    } catch (e) {
      _showResultDialog(
        'خطأ في الاتصال 📱',
        'تعذر الاتصال بالخادم.\nتأكد من اتصالك بالإنترنت وحاول مرة أخرى.',
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
                // Resume scanning is automatic with mobile_scanner
              },
              child: Text(
                'حاول مرة أخرى',
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
              'العودة للرئيسية',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}