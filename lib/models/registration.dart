// การลงทะเบียนกิจกรรม เก็บชื่อกับคณะไว้ด้วย ผู้คุมจะได้เห็นรายชื่อ
class Registration {
  final String activityId;
  final String studentId;
  final String studentName;
  final String faculty;
  final DateTime registeredAt;

  Registration({
    required this.activityId,
    required this.studentId,
    required this.studentName,
    required this.faculty,
    required this.registeredAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'activity_id': activityId,
      'student_id': studentId,
      'student_name': studentName,
      'faculty': faculty,
      'registered_at': registeredAt.millisecondsSinceEpoch,
    };
  }

  factory Registration.fromMap(Map<String, dynamic> map) {
    return Registration(
      activityId: map['activity_id'],
      studentId: map['student_id'],
      studentName: map['student_name'],
      faculty: map['faculty'],
      registeredAt: DateTime.fromMillisecondsSinceEpoch(map['registered_at']),
    );
  }
}
