// ชั่วโมงที่นิสิตได้จากกิจกรรม 1 กิจกรรม (ได้ครั้งเดียว)
class Credit {
  final String activityId;
  final String activityTitle;
  final String studentId;
  final double hours;
  final String kind; // 'จิตอาสา' หรือ 'กิจกรรมคณะ'
  final String method; // 'สแกน QR' หรือ 'ผู้คุมยืนยันให้'
  final double distance; // ระยะจากผู้คุม (เมตร) ถ้าผู้คุมยืนยันให้จะเป็น 0
  final String ref; // เลขอ้างอิง
  final DateTime verifiedAt;

  Credit({
    required this.activityId,
    required this.activityTitle,
    required this.studentId,
    required this.hours,
    required this.kind,
    required this.method,
    required this.distance,
    required this.ref,
    required this.verifiedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'activity_id': activityId,
      'activity_title': activityTitle,
      'student_id': studentId,
      'hours': hours,
      'kind': kind,
      'method': method,
      'distance': distance,
      'ref': ref,
      'verified_at': verifiedAt.millisecondsSinceEpoch,
    };
  }

  factory Credit.fromMap(Map<String, dynamic> map) {
    return Credit(
      activityId: map['activity_id'],
      activityTitle: map['activity_title'],
      studentId: map['student_id'],
      hours: map['hours'],
      kind: map['kind'],
      method: map['method'],
      distance: map['distance'],
      ref: map['ref'],
      verifiedAt: DateTime.fromMillisecondsSinceEpoch(map['verified_at']),
    );
  }
}
