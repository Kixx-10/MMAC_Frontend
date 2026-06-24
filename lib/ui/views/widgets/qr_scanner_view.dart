import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmac/data/controllers/qr_scan_provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class QrScannerView extends ConsumerStatefulWidget {

  final Function(String)? onScanned;
  const QrScannerView({
    super.key,
    this.onScanned});

  @override
  ConsumerState<QrScannerView> createState() => _QrScannerViewState();
}
class _QrScannerViewState extends ConsumerState<QrScannerView> {
  final MobileScannerController cameraController = MobileScannerController();
  PermissionStatus _permissionStatus = PermissionStatus.denied;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    if (kIsWeb) {
      setState(() { _permissionStatus = PermissionStatus.granted; _isLoading = false; });
      return;
    }
    final status = await Permission.camera.status;
    if (mounted) setState(() { _permissionStatus = status; _isLoading = false; });
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() => _permissionStatus = status);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    if (_permissionStatus.isGranted) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center( 
        child: SingleChildScrollView( 
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Container(
               width: 280,
               height: 280,
               decoration: BoxDecoration(
                 borderRadius: BorderRadius.circular(24),
                 border: Border.all(color: const Color(0xFF0B355B), width: 4),
               ),
               child: ClipRRect(
                 borderRadius: BorderRadius.circular(20),
                 child: MobileScanner(
                   key: const ValueKey('scanner_key'), 
                   controller: cameraController,
                   fit: BoxFit.cover,
                   onDetect: (capture) {
                     final barcodes = capture.barcodes;
                     if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                       cameraController.stop();
                       final String qrData = barcodes.first.rawValue!;
                       ref.read(qrScanProvider.notifier).verifyQrCode(barcodes.first.rawValue!);
                       widget.onScanned?.call(qrData);
                       //debugPrint('appNo:$qrData');
                     }
                   },
                 ),
               ),
             ),
           ],
         ),
                    ),
                  ),
      );
    }

    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: _requestCameraPermission,
          child: const Text("ALLOW CAMERA ACCESS"),
        ),
      ),
      
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}