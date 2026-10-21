class Announcement {
  final int? id;
  final String activityId;
  final String text;
  final DateTime createdAt;

  Announcement({
    this.id,
    required this.activityId,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activity_id': activityId,
      'text': text,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Announcement.fromMap(Map<String, dynamic> map) {
    return Announcement(
      id: map['id'],
      activityId: map['activity_id'],
      text: map['text'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }
}
