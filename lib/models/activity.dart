class Activity {
  final String id;
  final String title;
  final String kind;
  final String orgCode;
  final String orgName;
  final DateTime startAt;
  final DateTime endAt;
  final String place;
  final double hours;
  final int capacity;
  final String detail;
  final String poster;

  Activity({
    required this.id,
    required this.title,
    required this.kind,
    required this.orgCode,
    required this.orgName,
    required this.startAt,
    required this.endAt,
    required this.place,
    required this.hours,
    required this.capacity,
    required this.detail,
    required this.poster,
  });

  bool isOngoing() {
    final now = DateTime.now();
    return now.isAfter(startAt) && now.isBefore(endAt);
  }

  bool isPast() {
    return DateTime.now().isAfter(endAt);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'kind': kind,
      'org_code': orgCode,
      'org_name': orgName,
      'start_at': startAt.millisecondsSinceEpoch,
      'end_at': endAt.millisecondsSinceEpoch,
      'place': place,
      'hours': hours,
      'capacity': capacity,
      'detail': detail,
      'poster': poster,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'],
      title: map['title'],
      kind: map['kind'],
      orgCode: map['org_code'],
      orgName: map['org_name'],
      startAt: DateTime.fromMillisecondsSinceEpoch(map['start_at']),
      endAt: DateTime.fromMillisecondsSinceEpoch(map['end_at']),
      place: map['place'],
      hours: map['hours'],
      capacity: map['capacity'],
      detail: map['detail'],
      poster: map['poster'],
    );
  }
}
