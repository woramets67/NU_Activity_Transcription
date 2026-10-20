// ไฟล์ชั่วคราว สมาชิก3 จะแทนด้วยของจริง
import 'package:flutter/material.dart';

class ActivityEditorScreen extends StatelessWidget {
  final String? activityId;
  const ActivityEditorScreen({super.key, this.activityId});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('สร้างกิจกรรม')),
        body: const Center(child: Text('กำลังพัฒนา')),
      );
}
