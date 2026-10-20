class Student {
  final String studentId; // รหัสนิสิต 8 หลัก
  final String name;
  final String faculty;
  final String pinHash; // ไม่เก็บ PIN ตรงๆ เก็บแบบเข้ารหัส

  Student({
    required this.studentId,
    required this.name,
    required this.faculty,
    required this.pinHash,
  });

  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'name': name,
      'faculty': faculty,
      'pin_hash': pinHash,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      studentId: map['student_id'],
      name: map['name'],
      faculty: map['faculty'],
      pinHash: map['pin_hash'],
    );
  }
}
