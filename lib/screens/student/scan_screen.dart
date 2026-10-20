// ไฟล์ชั่วคราว สมาชิก2 จะแทนด้วยของจริง
import 'package:flutter/material.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('สแกน QR')),
        body: const Center(child: Text('กำลังพัฒนา')),
      );
}
