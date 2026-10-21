import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../models/activity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/supervisor_provider.dart';
import '../../utils/constants.dart';
import '../../utils/thai_date.dart';
import '../../utils/validators.dart';

// ฟอร์มกิจกรรม
// activityId เป็น null = สร้างใหม่
class ActivityEditorScreen extends StatefulWidget {
  final String? activityId;
  const ActivityEditorScreen({super.key, this.activityId});

  @override
  State<ActivityEditorScreen> createState() => _ActivityEditorScreenState();
}

class _ActivityEditorScreenState extends State<ActivityEditorScreen> {
  final List<String> _posters = [
    'assets/posters/blood.jpg',
    'assets/posters/river.jpg',
    'assets/posters/teach.jpg',
    'assets/posters/tree.jpg',
    'assets/posters/grad.jpg',
    'assets/posters/wai.jpg',
    'assets/posters/openhouse.jpg',
    'assets/posters/dorm.jpg',
  ];

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _placeController = TextEditingController();
  final _hoursController = TextEditingController(text: '3');
  final _capacityController = TextEditingController(text: '30');
  final _detailController = TextEditingController();

  String _kind = kVolunteer;
  String _poster = 'assets/posters/river.jpg';
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 12, minute: 0);

  Activity? _oldActivity;

  @override
  void initState() {
    super.initState();
    if (widget.activityId != null) {
      _oldActivity = context.read<SupervisorProvider>().findById(widget.activityId!);
      final a = _oldActivity;
      if (a != null) {
        _titleController.text = a.title;
        _placeController.text = a.place;
        _hoursController.text = '${a.hours}';
        _capacityController.text = '${a.capacity}';
        _detailController.text = a.detail;
        _kind = a.kind;
        _poster = a.poster;
        _date = a.startAt;
        _startTime = TimeOfDay.fromDateTime(a.startAt);
        _endTime = TimeOfDay.fromDateTime(a.endAt);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _placeController.dispose();
    _hoursController.dispose();
    _capacityController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  DateTime _combine(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final start = _combine(_date, _startTime);
    final end = _combine(_date, _endTime);
    if (!end.isAfter(start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เวลาจบต้องหลังเวลาเริ่ม')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final supProvider = context.read<SupervisorProvider>();
    final navigator = Navigator.of(context);

    final activity = Activity(
      id: _oldActivity?.id ?? 'a-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      kind: _kind,
      orgCode: auth.supOrgCode!,
      orgName: auth.supOrgName,
      startAt: start,
      endAt: end,
      place: _placeController.text.trim(),
      hours: double.parse(_hoursController.text),
      capacity: int.parse(_capacityController.text),
      detail: _detailController.text.trim(),
      poster: _poster,
    );

    await supProvider.saveActivity(activity, _oldActivity == null);
    navigator.pop();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_oldActivity == null ? 'สร้างกิจกรรม' : 'แก้ไขกิจกรรม')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('เลือกรูปโปสเตอร์'),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _posters.map((path) => _posterChoice(path)).toList(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'ชื่อกิจกรรม'),
              validator: validateRequired,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _kind,
              decoration: const InputDecoration(labelText: 'ประเภทชั่วโมง'),
              items: kActivityKinds.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
              onChanged: (value) => setState(() => _kind = value!),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('วันที่'),
                    trailing: Text(thaiDate(_date)),
                    onTap: _pickDate,
                  ),
                  ListTile(
                    leading: const Icon(Icons.schedule),
                    title: const Text('เวลาเริ่ม'),
                    trailing: Text(_startTime.format(context)),
                    onTap: () => _pickTime(true),
                  ),
                  ListTile(
                    leading: const Icon(Icons.schedule),
                    title: const Text('เวลาจบ'),
                    trailing: Text(_endTime.format(context)),
                    onTap: () => _pickTime(false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _placeController,
              decoration: const InputDecoration(labelText: 'สถานที่'),
              validator: validateRequired,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _hoursController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'ชั่วโมงที่ได้'),
                    validator: validatePositiveNumber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _capacityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'จำนวนที่รับ'),
                    validator: (value) {
                      final number = int.tryParse(value ?? '');
                      if (number == null || number <= 0) return 'ต้องเป็นจำนวนเต็มมากกว่า 0';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _detailController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'รายละเอียด'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: Text(_oldActivity == null ? 'เผยแพร่กิจกรรม' : 'บันทึก'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _posterChoice(String path) {
    final isSelected = _poster == path;
    return GestureDetector(
      onTap: () => setState(() => _poster = path),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? kOrange : Colors.transparent, width: 3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Image.asset(path, width: 110, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
