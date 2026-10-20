// ไฟล์ชั่วคราว สมาชิก3 จะแทนด้วยของจริง
import 'package:flutter/material.dart';

class ManageScreen extends StatelessWidget {
  final String activityId;
  const ManageScreen({super.key, required this.activityId});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('จัดการกิจกรรม')),
        body: const Center(child: Text('กำลังพัฒนา')),
      );
}
