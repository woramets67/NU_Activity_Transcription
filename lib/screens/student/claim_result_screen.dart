import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../models/claim_result.dart';
import '../../providers/auth_provider.dart';
import '../../utils/thai_date.dart';

// ผลการสแกน: ผ่านแสดงบัตรยืนยัน ไม่ผ่านบอกเหตุผล
class ClaimResultScreen extends StatelessWidget {
  final ClaimResult result;
  const ClaimResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(result.success ? 'รับชั่วโมงสำเร็จ' : 'รับชั่วโมงไม่สำเร็จ')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (result.success) _ticket(context) else _failCard(),
          const SizedBox(height: 24),
          if (!result.success)
            FilledButton(
              onPressed: () => Navigator.pushReplacementNamed(context, Routes.scan),
              child: const Text('สแกนอีกครั้ง'),
            ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('กลับหน้าหลัก'),
          ),
        ],
      ),
    );
  }

  Widget _failCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 56, color: kRed),
            const SizedBox(height: 12),
            Text(result.message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17)),
          ],
        ),
      ),
    );
  }

  // บัตรยืนยันแบบตั๋ว ส่วนบนสีส้ม ส่วนล่างเป็นรายละเอียด
  Widget _ticket(BuildContext context) {
    final credit = result.credit!;
    final student = context.read<AuthProvider>().student!;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: kOrange,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 48),
                Text('+${hoursText(credit.hours)}',
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                Text(credit.kind, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _row('กิจกรรม', credit.activityTitle),
                _row('ชื่อ', student.name),
                _row('รหัสนิสิต', student.studentId),
                _row('วันที่', thaiDate(credit.verifiedAt)),
                _row('เวลายืนยัน', thaiTime(credit.verifiedAt)),
                _row('ระยะจากผู้คุม', '${credit.distance.round()} ม.'),
                _row('เลขอ้างอิง', credit.ref),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(color: kGrey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
