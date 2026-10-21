import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/activity.dart';
import '../utils/thai_date.dart';

// Activity card
class ActivityCard extends StatelessWidget {
  final Activity activity;
  final String statusText;
  final Color statusColor;
  final VoidCallback onTap;

  const ActivityCard({
    super.key,
    required this.activity,
    required this.statusText,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(activity.poster, height: 180, width: double.infinity, fit: BoxFit.cover),
                Positioned(left: 12, top: 12, child: _label(activity.kind, kDark)),
                Positioned(right: 12, top: 12, child: _label(hoursText(activity.hours), kOrange)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(activity.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(thaiDateRange(activity.startAt, activity.endAt), style: const TextStyle(color: kGrey)),
                  Text(activity.place, style: const TextStyle(color: kGrey)),
                  const SizedBox(height: 8),
                  Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}
