import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';

// ผู้คุมเข้าระบบด้วยชื่อและรหัสหน่วยงาน (รหัสทดลอง NUVOL26 SCI2569 NUSA69)
class SupLoginScreen extends StatefulWidget {
  const SupLoginScreen({super.key});

  @override
  State<SupLoginScreen> createState() => _SupLoginScreenState();
}

class _SupLoginScreenState extends State<SupLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);
    final error = await context.read<AuthProvider>().enterSupervisor(
          _nameController.text,
          _codeController.text,
        );

    if (error == null) {
      navigator.pushReplacementNamed(Routes.supHome);
    } else {
      setState(() => _errorText = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เข้าโหมดผู้คุมกิจกรรม')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text('ใส่รหัสหน่วยงานที่ได้รับจากกองกิจการนิสิต', style: TextStyle(color: kGrey)),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'ชื่อผู้คุม'),
              validator: validateRequired,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'รหัสหน่วยงาน'),
              validator: validateRequired,
            ),
            if (_errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_errorText!, style: const TextStyle(color: kRed)),
              ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _submit, child: const Text('เข้าสู่ระบบ')),
          ],
        ),
      ),
    );
  }
}
