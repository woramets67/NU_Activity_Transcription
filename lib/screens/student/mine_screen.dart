// ไฟล์ชั่วคราว สมาชิก4 จะแทนด้วยของจริง
import 'package:flutter/material.dart';

class MineScreen extends StatelessWidget {
  const MineScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('กิจกรรมของฉัน')),
        body: const Center(child: Text('กำลังพัฒนา')),
      );
}
