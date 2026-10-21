import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../models/activity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/supervisor_provider.dart';
import '../../utils/thai_date.dart';

// หน้าหลักผู้คุม
class SupHomeScreen extends StatefulWidget {
  const SupHomeScreen({super.key});

  @override
  State<SupHomeScreen> createState() => _SupHomeScreenState();
}

class _SupHomeScreenState extends State<SupHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _reload());
  }

  Future<void> _reload() async {
    final orgCode = context.read<AuthProvider>().supOrgCode!;
    await context.read<SupervisorProvider>().loadActivities(orgCode);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final supProvider = context.watch<SupervisorProvider>();

    final ongoing = supProvider.activities.where((a) => a.isOngoing()).toList();
    final upcoming = supProvider.activities.where((a) => DateTime.now().isBefore(a.startAt)).toList();
    final past = supProvider.activities.where((a) => a.isPast()).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(auth.supOrgName),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'ออกจากโหมดผู้คุม',
            onPressed: () {
              auth.exitSupervisor();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, Routes.activityEditor, arguments: null);
          _reload();
        },
        icon: const Icon(Icons.add),
        label: const Text('สร้างกิจกรรม'),
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          children: [
            Text('ผู้คุม ${auth.supName}', style: const TextStyle(color: kGrey)),
            const SizedBox(height: 16),
            ..._section('กำลังดำเนินอยู่', ongoing, supProvider),
            ..._section('กำลังจะมาถึง', upcoming, supProvider),
            ..._section('จบแล้ว', past, supProvider),
          ],
        ),
      ),
    );
  }

  List<Widget> _section(String title, List<Activity> list, SupervisorProvider supProvider) {
    if (list.isEmpty) return [];
    return [
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      for (final a in list)
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(a.title),
            subtitle: Text(
              '${thaiDateRange(a.startAt, a.endAt)}\n'
              'ลงทะเบียน ${supProvider.registeredCount[a.id] ?? 0} จาก ${a.capacity} คน',
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await Navigator.pushNamed(context, Routes.manage, arguments: a.id);
              _reload();
            },
          ),
        ),
      const SizedBox(height: 16),
    ];
  }
}
