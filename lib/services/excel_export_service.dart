import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/activity.dart';
import '../providers/supervisor_provider.dart';
import '../utils/thai_date.dart';

// Export Excel
class ExcelExportService {
  static const List<String> headers = [
    'ลำดับ', 'รหัสนิสิต', 'ชื่อ', 'คณะ', 'กิจกรรม', 'ประเภท',
    'วันที่', 'ชั่วโมง', 'สถานะ', 'เวลายืนยัน', 'ยืนยันโดย',
  ];

  static List<List<String>> makeRows(Activity a, List<RosterItem> roster) {
    final rows = <List<String>>[];
    for (int i = 0; i < roster.length; i++) {
      final item = roster[i];
      final r = item.registration;
      final c = item.credit;
      rows.add([
        '${i + 1}',
        r.studentId,
        r.studentName,
        r.faculty,
        a.title,
        a.kind,
        thaiDate(a.startAt),
        item.hasCredit ? '${a.hours}' : '0',
        item.hasCredit ? 'ได้รับชั่วโมง' : 'ยังไม่ได้รับ',
        c != null ? '${thaiDate(c.verifiedAt)} ${thaiTime(c.verifiedAt)}' : '',
        c != null ? c.method : '',
      ]);
    }
    return rows;
  }

  static Future<void> exportAndShare(Activity a, List<RosterItem> roster) async {
    // 1. สร้างไฟล์
    final excel = Excel.createExcel();
    final sheet = excel[excel.getDefaultSheet()!];
    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());
    for (final row in makeRows(a, roster)) {
      sheet.appendRow(row.map((cell) => TextCellValue(cell)).toList());
    }

    // 2. บันทึก
    final folder = await getTemporaryDirectory();
    final file = File('${folder.path}/รายชื่อ_${a.id}.xlsx');
    await file.writeAsBytes(excel.encode()!);

    // 3. แชร์
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: a.title));
  }
}
