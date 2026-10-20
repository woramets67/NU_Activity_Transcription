// ไฟล์ชั่วคราว สมาชิก4 จะแทนด้วยของจริง
import 'package:flutter/material.dart';

class ActivityDetailScreen extends StatelessWidget {
  final String activityId;
  const ActivityDetailScreen({super.key, required this.activityId});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('กิจกรรม')),
        body: const Center(child: Text('กำลังพัฒนา')),
      );
}
