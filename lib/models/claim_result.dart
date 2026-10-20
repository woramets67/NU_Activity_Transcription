import 'credit.dart';

// ผลการสแกน QR
// ถ้าผ่าน success = true และมี credit
// ถ้าไม่ผ่าน success = false และ message บอกเหตุผล
class ClaimResult {
  final bool success;
  final String message;
  final Credit? credit;

  ClaimResult({required this.success, required this.message, this.credit});
}
