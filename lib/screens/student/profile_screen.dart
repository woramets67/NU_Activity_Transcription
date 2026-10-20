import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/credit_provider.dart';
import '../../utils/constants.dart';
import '../../utils/thai_date.dart';

// หน้า Transcript ชั่วโมงสะสม แยกจิตอาสากับกิจกรรมคณะ (R3)
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final creditProvider = context.watch<CreditProvider>();
    final student = auth.student!;

    return Scaffold(
      appBar: AppBar(title: const Text('Transcript')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          // การ์ดสีเข้ม แสดงชื่อและชั่วโมงรวม
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kDark,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset('assets/nu-emblem.png', height: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(student.name,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('${student.studentId} คณะ${student.faculty}',
                              style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  hoursText(creditProvider.totalHours),
                  style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.bold),
                ),
                const Text('ชั่วโมงสะสมทั้งหมด', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _kindSummary(creditProvider, kVolunteer),
                    _kindSummary(creditProvider, kFacultyActivity),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text('กิจกรรมที่ได้ชั่วโมง', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (creditProvider.credits.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('ยังไม่มีชั่วโมง สแกน QR ในกิจกรรมเพื่อรับชั่วโมง',
                  textAlign: TextAlign.center, style: TextStyle(color: kGrey)),
            ),
          for (final c in creditProvider.credits)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(c.activityTitle),
                subtitle: Text('${thaiDate(c.verifiedAt)} ${c.method} เลขอ้างอิง ${c.ref}'),
                trailing: Text(hoursText(c.hours),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          const SizedBox(height: 24),

          OutlinedButton.icon(
            onPressed: () {
              // ถ้าเคยเข้าโหมดผู้คุมแล้วไปหน้าผู้คุมเลย ถ้ายังให้ใส่รหัสก่อน
              if (auth.isSupervisor) {
                Navigator.pushNamed(context, Routes.supHome);
              } else {
                Navigator.pushNamed(context, Routes.supLogin);
              }
            },
            icon: const Icon(Icons.badge_outlined),
            label: const Text('เข้าโหมดผู้คุมกิจกรรม'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => auth.signOut(),
            child: const Text('ออกจากระบบ', style: TextStyle(color: kRed)),
          ),
        ],
      ),
    );
  }

  // ชั่วโมงของแต่ละประเภท เช่น "13 ชม. จิตอาสา 3 กิจกรรม"
  Widget _kindSummary(CreditProvider creditProvider, String kind) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hoursText(creditProvider.hoursOfKind(kind)),
            style: const TextStyle(color: kOrange, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text('$kind ${creditProvider.countOfKind(kind)} กิจกรรม',
              style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
