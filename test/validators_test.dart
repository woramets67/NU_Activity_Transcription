import 'package:flutter_test/flutter_test.dart';
import 'package:nu_activity_transcript/utils/validators.dart';

void main() {
  test('รหัสนิสิต 8 หลักผ่าน', () {
    expect(validateStudentId('67310011'), null);
  });

  test('รหัสนิสิต 7 หลักไม่ผ่าน', () {
    expect(validateStudentId('6731001'), isNotNull);
  });

  test('รหัสนิสิตมีตัวอักษรไม่ผ่าน', () {
    expect(validateStudentId('6731001a'), isNotNull);
  });

  test('PIN 6 หลักผ่าน', () {
    expect(validatePin('123456'), null);
  });

  test('PIN ว่างไม่ผ่าน', () {
    expect(validatePin(''), isNotNull);
  });
}
