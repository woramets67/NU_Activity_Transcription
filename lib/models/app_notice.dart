class AppNotice {
  final int? id;
  final String studentId;
  final String activityId;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  AppNotice({
    this.id,
    required this.studentId,
    required this.activityId,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'activity_id': activityId,
      'title': title,
      'body': body,
      'created_at': createdAt.millisecondsSinceEpoch,
      'is_read': isRead ? 1 : 0,
    };
  }

  factory AppNotice.fromMap(Map<String, dynamic> map) {
    return AppNotice(
      id: map['id'],
      studentId: map['student_id'],
      activityId: map['activity_id'],
      title: map['title'],
      body: map['body'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      isRead: map['is_read'] == 1,
    );
  }
}
