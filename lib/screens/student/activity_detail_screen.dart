import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../models/activity.dart';
import '../../models/announcement.dart';
import '../../providers/activity_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/credit_provider.dart';
import '../../utils/thai_date.dart';

// Activity detail
class ActivityDetailScreen extends StatelessWidget {
  final String activityId;
  const ActivityDetailScreen({super.key, required this.activityId});

  @override
  Widget build(BuildContext context) {
    final activityProvider = context.watch<ActivityProvider>();
    final activity = activityProvider.findById(activityId);

    if (activity == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('ไม่พบกิจกรรมนี้')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('รายละเอียดกิจกรรม')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Image.asset(activity.poster, height: 220, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${activity.kind} ${activity.orgName}', style: const TextStyle(color: kOrange)),
                const SizedBox(height: 6),
                Text(activity.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _infoRow(Icons.schedule, thaiDateRange(activity.startAt, activity.endAt)),
                _infoRow(Icons.place_outlined, activity.place),
                _infoRow(Icons.workspace_premium_outlined, 'ได้ ${hoursText(activity.hours)} ${activity.kind}'),
                _infoRow(Icons.groups_outlined,
                    'ลงทะเบียน ${activityProvider.registeredCount[activity.id] ?? 0} จาก ${activity.capacity} คน'),
                const SizedBox(height: 16),
                Text(activity.detail, style: const TextStyle(height: 1.6)),
                const SizedBox(height: 24),
                _actionButton(context, activity),
                const SizedBox(height: 24),
                const Text('ประกาศจากผู้คุม', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _announcementList(activityProvider, activity),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: kGrey),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, Activity activity) {
    final activityProvider = context.watch<ActivityProvider>();
    final creditProvider = context.watch<CreditProvider>();

    if (creditProvider.hasCredit(activity.id)) {
      return const FilledButton(onPressed: null, child: Text('ได้รับชั่วโมงแล้ว'));
    }
    if (activityProvider.isRegistered(activity.id)) {
      if (activity.isOngoing()) {
        return FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: kOrange),
          onPressed: () => Navigator.pushNamed(context, Routes.scan),
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('สแกนรับชั่วโมง'),
        );
      }
      return OutlinedButton(
        onPressed: () => _confirmCancel(context, activity),
        child: const Text('ลงทะเบียนแล้ว แตะเพื่อยกเลิก'),
      );
    }
    if (activity.isPast()) {
      return const FilledButton(onPressed: null, child: Text('กิจกรรมจบแล้ว'));
    }
    if (activityProvider.isFull(activity)) {
      return const FilledButton(onPressed: null, child: Text('เต็มแล้ว'));
    }
    return FilledButton(
      onPressed: () => _confirmRegister(context, activity),
      child: const Text('ลงทะเบียน'),
    );
  }

  Future<void> _confirmRegister(BuildContext context, Activity activity) async {
    final activityProvider = context.read<ActivityProvider>();
    final student = context.read<AuthProvider>().student!;
    final messenger = ScaffoldMessenger.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ยืนยันการลงทะเบียน'),
        content: Text('${activity.title}\n${thaiDateRange(activity.startAt, activity.endAt)}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('ยกเลิก')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('ลงทะเบียน')),
        ],
      ),
    );
    if (confirm != true) return;

    final error = await activityProvider.register(activity, student);
    messenger.showSnackBar(SnackBar(content: Text(error ?? 'ลงทะเบียนสำเร็จ')));
  }

  Future<void> _confirmCancel(BuildContext context, Activity activity) async {
    final activityProvider = context.read<ActivityProvider>();
    final student = context.read<AuthProvider>().student!;
    final messenger = ScaffoldMessenger.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ยกเลิกการลงทะเบียน?'),
        content: const Text('ที่นั่งจะคืนให้คนอื่นลงทะเบียนได้ทันที'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('ไม่ยกเลิก')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('ยกเลิก')),
        ],
      ),
    );
    if (confirm != true) return;

    final error = await activityProvider.cancel(activity, student);
    messenger.showSnackBar(SnackBar(content: Text(error ?? 'ยกเลิกแล้ว')));
  }

  Widget _announcementList(ActivityProvider activityProvider, Activity activity) {
    return FutureBuilder<List<Announcement>>(
      future: activityProvider.getAnnouncements(activity.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LinearProgressIndicator();
        }
        final announcements = snapshot.data!;
        if (announcements.isEmpty) {
          return const Text('ยังไม่มีประกาศ', style: TextStyle(color: kGrey));
        }
        return Column(
          children: announcements.map((a) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(a.text),
                subtitle: Text('${thaiDate(a.createdAt)} ${thaiTime(a.createdAt)}'),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
