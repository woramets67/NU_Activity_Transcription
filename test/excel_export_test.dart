import 'package:flutter_test/flutter_test.dart';
import 'package:nu_activity_transcript/helpers/seed_data.dart';
import 'package:nu_activity_transcript/models/credit.dart';
import 'package:nu_activity_transcript/providers/supervisor_provider.dart';
import 'package:nu_activity_transcript/services/excel_export_service.dart';
import 'package:nu_activity_transcript/utils/constants.dart';

void main() {
  test('Excel มีครบทุกคน ทุกคอลัมน์ และสถานะถูกต้อง', () {
    final activity = seedActivities().first;
    final registrations = seedRegistrations().where((r) => r.activityId == activity.id).toList();

    // คนแรกได้ชั่วโมงแล้ว คนที่ 2 กับ 3 ยังไม่ได้
    final credit = Credit(
      activityId: activity.id,
      activityTitle: activity.title,
      studentId: registrations[0].studentId,
      hours: activity.hours,
      kind: activity.kind,
      method: kByQr,
      distance: 40,
      ref: 'ABCD1234',
      verifiedAt: DateTime.now(),
    );
    final roster = [
      RosterItem(registrations[0], credit),
      RosterItem(registrations[1], null),
      RosterItem(registrations[2], null),
    ];

    final rows = ExcelExportService.makeRows(activity, roster);

    expect(rows.length, 3);
    for (final row in rows) {
      expect(row.length, ExcelExportService.headers.length);
    }
    expect(rows[0][1], registrations[0].studentId);
    expect(rows[0][8], 'ได้รับชั่วโมง');
    expect(rows[1][8], 'ยังไม่ได้รับ');
  });
}
