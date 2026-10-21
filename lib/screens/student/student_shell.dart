import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/credit_provider.dart';
import '../../providers/notice_provider.dart';
import 'home_screen.dart';
import 'inbox_screen.dart';
import 'mine_screen.dart';
import 'profile_screen.dart';

// แถบล่างของนิสิต
class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _currentTab = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    MineScreen(),
    InboxScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final studentId = context.read<AuthProvider>().student!.studentId;
      context.read<CreditProvider>().loadCredits(studentId);
      context.read<NoticeProvider>().loadNotices(studentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<NoticeProvider>().unreadCount;

    return Scaffold(
      body: IndexedStack(index: _currentTab, children: _pages),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () => Navigator.pushNamed(context, Routes.scan),
        backgroundColor: kOrange,
        foregroundColor: Colors.white,
        child: const Icon(Icons.qr_code_scanner, size: 36),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (index) => setState(() => _currentTab = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kDark,
        unselectedItemColor: kGrey,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'หน้าแรก'),
          const BottomNavigationBarItem(icon: Icon(Icons.event_note_outlined), label: 'ของฉัน'),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text('$unread'),
              child: const Icon(Icons.notifications_outlined),
            ),
            label: 'แจ้งเตือน',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Transcript'),
        ],
      ),
    );
  }
}
