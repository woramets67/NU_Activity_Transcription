import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nu_activity_transcript/helpers/seed_data.dart';
import 'package:nu_activity_transcript/widgets/activity_card.dart';

// Widget test
void main() {
  testWidgets('การ์ดกิจกรรมแสดงชื่อ ประเภท และสถานะ แล้วกดได้', (tester) async {
    final activity = seedActivities().first;
    bool tapped = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ActivityCard(
            activity: activity,
            statusText: 'เหลือ 5 ที่',
            statusColor: Colors.grey,
            onTap: () => tapped = true,
          ),
        ),
      ),
    ));

    expect(find.text(activity.title), findsOneWidget);
    expect(find.text('จิตอาสา'), findsOneWidget);
    expect(find.text('เหลือ 5 ที่'), findsOneWidget);

    await tester.tap(find.text(activity.title));
    expect(tapped, true);
  });
}
