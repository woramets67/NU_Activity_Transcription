import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../models/activity.dart';
import '../../providers/activity_provider.dart';
import '../../providers/credit_provider.dart';
import '../../utils/thai_date.dart';
import 'home_screen.dart';

// My activities
class MineScreen extends StatelessWidget {
  const MineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activityProvider = context.watch<ActivityProvider>();
    final creditProvider = context.watch<CreditProvider>();

    final upcoming = activityProvider.myActivities.where((a) => !a.isPast()).toList();
    final past = activityProvider.myActivities.where((a) => a.isPast()).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('กิจกรรมของฉัน')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
        children: [
          const Text('กำลังจะถึง', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (upcoming.isEmpty) const Text('ยังไม่มีกิจกรรม', style: TextStyle(color: kGrey)),
          for (final a in upcoming)
            _activityTile(
              context,
              a,
              '${daysFromNow(a.startAt)}\n${statusText(activityProvider, creditProvider, a)}',
            ),
          const SizedBox(height: 24),
          const Text('ที่ผ่านมา', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (past.isEmpty) const Text('ยังไม่มีกิจกรรม', style: TextStyle(color: kGrey)),
          for (final a in past)
            _activityTile(
              context,
              a,
              creditProvider.hasCredit(a.id)
                  ? '${thaiDate(a.startAt)}\nได้ ${hoursText(a.hours)}'
                  : '${thaiDate(a.startAt)}\nไม่ได้รับชั่วโมง',
            ),
        ],
      ),
    );
  }

  Widget _activityTile(BuildContext context, Activity a, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(a.poster, width: 56, height: 56, fit: BoxFit.cover),
        ),
        title: Text(a.title),
        subtitle: Text(subtitle),
        isThreeLine: true,
        onTap: () => Navigator.pushNamed(context, Routes.activityDetail, arguments: a.id),
      ),
    );
  }
}
