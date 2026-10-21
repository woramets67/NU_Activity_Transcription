import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/credit_provider.dart';
import '../../providers/notice_provider.dart';
import '../../services/claim_service.dart';

// หน้าสแกน
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _cameraController = MobileScannerController();
  bool _isChecking = false;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isChecking) return;
    final qrText = capture.barcodes.first.rawValue;
    if (qrText == null) return;

    setState(() => _isChecking = true);
    await _cameraController.stop();

    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    final creditProvider = context.read<CreditProvider>();
    final noticeProvider = context.read<NoticeProvider>();
    final navigator = Navigator.of(context);

    final result = await ClaimService().checkAndSave(qrText, auth.student!);

    if (result.success) {
      await creditProvider.loadCredits(auth.student!.studentId);
      await noticeProvider.refresh();
    }
    navigator.pushReplacementNamed(Routes.claimResult, arguments: result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('สแกน QR รับชั่วโมง'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _cameraController, onDetect: _onDetect),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: kOrange, width: 4),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 48,
            child: Text(
              _isChecking ? 'กำลังตรวจ QR และตำแหน่ง GPS' : 'ส่องกล้องไปที่ QR บนจอของผู้คุมกิจกรรม',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          if (_isChecking) const Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      ),
    );
  }
}
