import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../app/theme.dart';
import '../../models/activity.dart';
import '../../services/location_service.dart';
import '../../services/qr_service.dart';
import '../../utils/constants.dart';
import '../../utils/thai_date.dart';

// จอ QR ของผู้คุม QR เปลี่ยนทุก 10 วินาที ใช้ Timer นับถอยหลัง
class QrPresenterScreen extends StatefulWidget {
  final Activity activity;
  const QrPresenterScreen({super.key, required this.activity});

  @override
  State<QrPresenterScreen> createState() => _QrPresenterScreenState();
}

class _QrPresenterScreenState extends State<QrPresenterScreen> {
  Timer? _timer;
  double? _lat; // ตำแหน่งของผู้คุม
  double? _lng;
  String? _qrText;
  String? _errorText;
  int _secondsLeft = kQrChangeEvery;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    // อ่านตำแหน่งผู้คุมก่อน เพราะต้องใส่ลงใน QR
    final position = await LocationService.getCurrentPosition();
    if (!mounted) return; // ผู้ใช้ออกจากหน้านี้ไปแล้ว
    if (position == null) {
      setState(() => _errorText = 'กรุณาเปิด GPS และอนุญาตตำแหน่งก่อนเปิด QR');
      return;
    }
    _lat = position.latitude;
    _lng = position.longitude;
    _makeNewQr();

    // ทุก 1 วินาที ลดตัวเลขลง ครบแล้วสร้าง QR ใหม่
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        _makeNewQr();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _makeNewQr() {
    setState(() {
      _qrText = QrService.createQrText(widget.activity, _lat!, _lng!);
      _secondsLeft = kQrChangeEvery;
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // ปิด Timer เมื่อออกจากหน้านี้
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // พื้นขาวสแกนง่าย
      appBar: AppBar(title: const Text('QR รับชั่วโมง'), backgroundColor: Colors.white),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.activity.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('${hoursText(widget.activity.hours)} ${widget.activity.kind}',
                  style: const TextStyle(color: kGrey)),
              const SizedBox(height: 24),
              _qrArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _qrArea() {
    if (_errorText != null) {
      return Text(_errorText!, style: const TextStyle(color: kRed));
    }
    if (_qrText == null) {
      return const CircularProgressIndicator();
    }
    return Column(
      children: [
        QrImageView(data: _qrText!, size: 300),
        const SizedBox(height: 16),
        SizedBox(
          width: 300,
          child: LinearProgressIndicator(
            value: _secondsLeft / kQrChangeEvery,
            color: kOrange,
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 8),
        Text('QR ใหม่ใน $_secondsLeft วินาที'),
      ],
    );
  }
}
