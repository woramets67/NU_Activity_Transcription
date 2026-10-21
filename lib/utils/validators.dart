// ตรวจข้อมูลฟอร์ม

String? validateRequired(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'กรุณากรอกข้อมูล';
  }
  return null;
}

String? validateStudentId(String? value) {
  if (value == null || value.isEmpty) {
    return 'กรุณากรอกรหัสนิสิต';
  }
  if (value.length != 8 || int.tryParse(value) == null) {
    return 'รหัสนิสิตต้องเป็นตัวเลข 8 หลัก';
  }
  return null;
}

String? validatePin(String? value) {
  if (value == null || value.isEmpty) {
    return 'กรุณากรอก PIN';
  }
  if (value.length != 6 || int.tryParse(value) == null) {
    return 'PIN ต้องเป็นตัวเลข 6 หลัก';
  }
  return null;
}

String? validatePositiveNumber(String? value) {
  final number = double.tryParse(value ?? '');
  if (number == null || number <= 0) {
    return 'ต้องเป็นตัวเลขมากกว่า 0';
  }
  return null;
}
