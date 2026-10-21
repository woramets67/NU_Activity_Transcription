import 'credit.dart';

class ClaimResult {
  final bool success;
  final String message;
  final Credit? credit;

  ClaimResult({required this.success, required this.message, this.credit});
}
