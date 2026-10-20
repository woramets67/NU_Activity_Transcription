// ไฟล์ชั่วคราว สมาชิก2 จะแทนด้วยของจริง
import 'package:flutter/material.dart';

import '../../models/activity.dart';

class QrPresenterScreen extends StatelessWidget {
  final Activity activity;
  const QrPresenterScreen({super.key, required this.activity});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('QR รับชั่วโมง')),
        body: const Center(child: Text('กำลังพัฒนา')),
      );
}
