// ไฟล์ชั่วคราว สมาชิก4 จะแทนด้วยของจริง
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('หน้าแรก')),
        body: const Center(child: Text('กำลังพัฒนา')),
      );
}
