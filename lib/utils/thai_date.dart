// ฟังก์ชันแสดงวันที่แบบไทย ปี พ.ศ.

const List<String> _months = [
  'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
  'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
];

// 20 ต.ค. 2569
String thaiDate(DateTime d) {
  return '${d.day} ${_months[d.month - 1]} ${d.year + 543}';
}

// 09:30
String thaiTime(DateTime d) {
  final hour = d.hour.toString().padLeft(2, '0');
  final minute = d.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

// 20 ต.ค. 2569 09:00 ถึง 12:00
String thaiDateRange(DateTime start, DateTime end) {
  return '${thaiDate(start)} ${thaiTime(start)} ถึง ${thaiTime(end)}';
}

// วันนี้ พรุ่งนี้ หรือ อีก 3 วัน
String daysFromNow(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final thatDay = DateTime(d.year, d.month, d.day);
  final diff = thatDay.difference(today).inDays;
  if (diff == 0) return 'วันนี้';
  if (diff == 1) return 'พรุ่งนี้';
  if (diff > 1) return 'อีก $diff วัน';
  return '${-diff} วันที่แล้ว';
}

// 4 ชม. หรือ 1.5 ชม.
String hoursText(double hours) {
  if (hours == hours.roundToDouble()) {
    return '${hours.toInt()} ชม.';
  }
  return '$hours ชม.';
}
