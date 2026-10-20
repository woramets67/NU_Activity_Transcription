// ไฟล์ชั่วคราว สมาชิก3 จะแทนด้วยของจริง
import 'package:flutter/material.dart';

class SupHomeScreen extends StatelessWidget {
  const SupHomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('ผู้คุม')),
        body: const Center(child: Text('กำลังพัฒนา')),
      );
}
