import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../providers/notice_provider.dart';
import '../../utils/thai_date.dart';

// กล่องแจ้งเตือน มีจุดส้มบอกว่ายังไม่อ่าน กดแล้วไปหน้ากิจกรรม (R5)
class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final noticeProvider = context.watch<NoticeProvider>();
    final notices = noticeProvider.notices;

    return Scaffold(
      appBar: AppBar(
        title: const Text('แจ้งเตือน'),
        actions: [
          if (noticeProvider.unreadCount > 0)
            TextButton(
              onPressed: () => noticeProvider.markAllRead(),
              child: const Text('อ่านทั้งหมด'),
            ),
        ],
      ),
      body: notices.isEmpty
          ? const Center(child: Text('ยังไม่มีแจ้งเตือน', style: TextStyle(color: kGrey)))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              itemCount: notices.length,
              itemBuilder: (context, index) {
                final notice = notices[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(Icons.campaign_outlined, color: notice.isRead ? kGrey : kOrange),
                    title: Text(
                      notice.title,
                      style: TextStyle(fontWeight: notice.isRead ? FontWeight.normal : FontWeight.bold),
                    ),
                    subtitle: Text('${notice.body}\n${thaiDate(notice.createdAt)} ${thaiTime(notice.createdAt)}'),
                    isThreeLine: true,
                    trailing: notice.isRead
                        ? null
                        : const CircleAvatar(radius: 5, backgroundColor: kOrange),
                    onTap: () {
                      noticeProvider.markRead(notice);
                      Navigator.pushNamed(context, Routes.activityDetail, arguments: notice.activityId);
                    },
                  ),
                );
              },
            ),
    );
  }
}
