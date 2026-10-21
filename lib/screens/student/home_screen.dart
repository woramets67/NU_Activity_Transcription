import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../models/activity.dart';
import '../../providers/activity_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/credit_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/activity_card.dart';

// Home
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _reload());
  }

  Future<void> _reload() async {
    final studentId = context.read<AuthProvider>().student!.studentId;
    await context.read<ActivityProvider>().loadActivities(studentId);
  }

  @override
  Widget build(BuildContext context) {
    final activityProvider = context.watch<ActivityProvider>();
    final creditProvider = context.watch<CreditProvider>();
    final student = context.watch<AuthProvider>().student!;
    final list = activityProvider.openActivities;

    return Scaffold(
      appBar: AppBar(title: Text('สวัสดี ${student.name}')),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
          itemCount: list.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _filterRow(activityProvider);
            }
            final activity = list[index - 1];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ActivityCard(
                activity: activity,
                statusText: statusText(activityProvider, creditProvider, activity),
                statusColor: statusColor(activityProvider, creditProvider, activity),
                onTap: () => Navigator.pushNamed(context, Routes.activityDetail, arguments: activity.id),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _filterRow(ActivityProvider activityProvider) {
    final filters = ['ทั้งหมด', ...kActivityKinds];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'ค้นหากิจกรรม'),
          onChanged: (text) => activityProvider.setSearchText(text),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: filters.map((f) {
            return ChoiceChip(
              label: Text(f),
              selected: activityProvider.filter == f,
              onSelected: (value) => activityProvider.setFilter(f),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        if (activityProvider.openActivities.isEmpty)
          const Text('ไม่พบกิจกรรม', style: TextStyle(color: kGrey)),
      ],
    );
  }
}

String statusText(ActivityProvider p, CreditProvider c, Activity a) {
  if (c.hasCredit(a.id)) return 'ได้รับชั่วโมงแล้ว';
  if (p.isRegistered(a.id) && a.isOngoing()) return 'กำลังดำเนินอยู่ สแกนรับชั่วโมงได้';
  if (p.isRegistered(a.id)) return 'ลงทะเบียนแล้ว';
  if (p.isFull(a)) return 'เต็มแล้ว';
  return 'เหลือ ${p.seatsLeft(a)} ที่';
}

Color statusColor(ActivityProvider p, CreditProvider c, Activity a) {
  if (c.hasCredit(a.id)) return kGreen;
  if (p.isRegistered(a.id) && a.isOngoing()) return kOrange;
  if (p.isRegistered(a.id)) return kDark;
  if (p.isFull(a)) return kRed;
  return kGrey;
}
