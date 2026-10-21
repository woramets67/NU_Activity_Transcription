class Credit {
  final String activityId;
  final String activityTitle;
  final String studentId;
  final double hours;
  final String kind;
  final String method;
  final double distance; // เมตร
  final String ref;
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
