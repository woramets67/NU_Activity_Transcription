import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';

// หน้าสมัครและเข้าสู่ระบบ ใช้ Form กับ TextFormField (บทที่ 8)
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();
  final _pin2Controller = TextEditingController();

  String? _faculty;
  bool _isSignUp = true; // true = สมัครใหม่, false = เข้าสู่ระบบ
  String? _errorText;

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _pinController.dispose();
    _pin2Controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    String? error;
    if (_isSignUp) {
      error = await auth.signUp(
        _idController.text,
        _nameController.text,
        _faculty!,
        _pinController.text,
      );
    } else {
      error = await auth.signIn(_idController.text, _pinController.text);
    }
    // ถ้าสำเร็จ StartScreen ใน main.dart จะพาไปหน้าหลักเอง
    setState(() {
      _errorText = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Image.asset('assets/nu-emblem.png', height: 72, alignment: Alignment.centerLeft),
              const SizedBox(height: 24),
              const Text(
                'NU Activity Transcript',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const Text('เก็บชั่วโมงจิตอาสาและกิจกรรมคณะของนิสิต มน.', style: TextStyle(color: kGrey)),
              const SizedBox(height: 24),

              // ปุ่มสลับ สมัครใหม่ หรือ เข้าสู่ระบบ
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('สมัครใหม่')),
                      selected: _isSignUp,
                      onSelected: (value) => setState(() => _isSignUp = true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('เข้าสู่ระบบ')),
                      selected: !_isSignUp,
                      onSelected: (value) => setState(() => _isSignUp = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _idController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'รหัสนิสิต'),
                validator: validateStudentId,
              ),
              const SizedBox(height: 12),

              // ช่องที่มีเฉพาะตอนสมัคร
              if (_isSignUp) ...[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'ชื่อ นามสกุล'),
                  validator: validateRequired,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _faculty,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'คณะ'),
                  items: kFaculties
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (value) => setState(() => _faculty = value),
                  validator: (value) => value == null ? 'กรุณาเลือกคณะ' : null,
                ),
                const SizedBox(height: 12),
              ],

              TextFormField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'PIN 6 หลัก'),
                validator: validatePin,
              ),
              const SizedBox(height: 12),

              if (_isSignUp)
                TextFormField(
                  controller: _pin2Controller,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'ยืนยัน PIN อีกครั้ง'),
                  validator: (value) => value != _pinController.text ? 'PIN ไม่ตรงกัน' : null,
                ),

              if (_errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_errorText!, style: const TextStyle(color: kRed)),
                ),
              const SizedBox(height: 24),

              FilledButton(
                onPressed: _submit,
                child: Text(_isSignUp ? 'สมัครและเริ่มใช้งาน' : 'เข้าสู่ระบบ'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, Routes.supLogin),
                child: const Text('เข้าใช้งานในฐานะผู้คุมกิจกรรม'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
