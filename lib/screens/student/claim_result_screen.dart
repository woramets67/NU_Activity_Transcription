// ไฟล์ชั่วคราว สมาชิก2 จะแทนด้วยของจริง
import 'package:flutter/material.dart';

import '../../models/claim_result.dart';

class ClaimResultScreen extends StatelessWidget {
  final ClaimResult result;
  const ClaimResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('ผลการสแกน')),
        body: const Center(child: Text('กำลังพัฒนา')),
      );
}
