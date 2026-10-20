import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/routes.dart';
import 'app/theme.dart';
import 'providers/activity_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/credit_provider.dart';
import 'providers/notice_provider.dart';
import 'providers/supervisor_provider.dart';
import 'screens/student/student_shell.dart';
import 'screens/student/welcome_screen.dart';

void main() {
  runApp(
    // ใช้ MultiProvider เพราะมี Provider หลายตัว (บทที่ 11)
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()..loadSavedLogin()),
        ChangeNotifierProvider(create: (context) => ActivityProvider()),
        ChangeNotifierProvider(create: (context) => CreditProvider()),
        ChangeNotifierProvider(create: (context) => NoticeProvider()),
        ChangeNotifierProvider(create: (context) => SupervisorProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NU Activity Transcript',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      home: const StartScreen(),
      onGenerateRoute: generateRoute,
    );
  }
}

// หน้าแรกสุด: ยังไม่เข้าระบบไปหน้า Welcome เข้าแล้วไปหน้าหลักของนิสิต
class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (auth.student == null) {
      return const WelcomeScreen();
    }
    return const StudentShell();
  }
}
