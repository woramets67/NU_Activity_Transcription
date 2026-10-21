import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../models/activity.dart';
import '../../providers/supervisor_provider.dart';
import '../../services/excel_export_service.dart';
import '../../utils/constants.dart';
import '../../utils/thai_date.dart';
import '../../utils/validators.dart';

// จัดการกิจกรรม: เปิด QR, รายชื่อ, ค้นหา, เพิ่มชื่อเอง, ประกาศ, export Excel (R4 และ R5)
class ManageScreen extends StatefulWidget {
  final String activityId;
  const ManageScreen({super.key, required this.activityId});

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final supProvider = context.read<SupervisorProvider>();
      supProvider.setSearchText('');
      supProvider.setRosterFilter('ทั้งหมด');
      supProvider.loadRoster(widget.activityId);
    });
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final supProvider = context.watch<SupervisorProvider>();
    final activity = supProvider.findById(widget.activityId);

    if (activity == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('ไม่พบกิจกรรมนี้')));
    }
    final list = supProvider.filteredRoster;

    return Scaffold(
      appBar: AppBar(
        title: Text(activity.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'แก้ไขกิจกรรม',
            onPressed: () => Navigator.pushNamed(context, Routes.activityEditor, arguments: activity.id),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(thaiDateRange(activity.startAt, activity.endAt), style: const TextStyle(color: kGrey)),
          const SizedBox(height: 12),

          // ตัวเลขสรุป
          Row(
            children: [
              _numberCard('ลงทะเบียน', supProvider.roster.length),
              const SizedBox(width: 8),
              _numberCard('ได้ชั่วโมงแล้ว', supProvider.creditedCount),
            ],
          ),
          const SizedBox(height: 12),

          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: kOrange),
            onPressed: () => Navigator.pushNamed(context, Routes.qrPresenter, arguments: activity),
            icon: const Icon(Icons.qr_code_2),
            label: const Text('เปิด QR รับชั่วโมง'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showAnnounceDialog(activity),
                  icon: const Icon(Icons.campaign_outlined),
                  label: const Text('ประกาศ'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => ExcelExportService.exportAndShare(activity, supProvider.roster),
                  icon: const Icon(Icons.table_view_outlined),
                  label: const Text('Export Excel'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // หัวข้อรายชื่อ และปุ่มเพิ่มนิสิตเอง
          Row(
            children: [
              const Text('รายชื่อ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showAddDialog(activity),
                icon: const Icon(Icons.person_add_alt),
                label: const Text('เพิ่มนิสิตเอง'),
              ),
            ],
          ),
          TextField(
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'ค้นหาชื่อหรือรหัสนิสิต'),
            onChanged: (text) => supProvider.setSearchText(text),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['ทั้งหมด', 'ได้ชั่วโมงแล้ว', 'ยังไม่ได้'].map((f) {
              return ChoiceChip(
                label: Text(f),
                selected: supProvider.rosterFilter == f,
                onSelected: (value) => supProvider.setRosterFilter(f),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('ไม่พบรายชื่อ', textAlign: TextAlign.center, style: TextStyle(color: kGrey)),
            ),
          for (final item in list)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(item.registration.studentName),
                subtitle: Text('${item.registration.studentId} คณะ${item.registration.faculty}'),
                trailing: item.hasCredit
                    ? Text(item.credit!.method, style: const TextStyle(color: kGreen))
                    : const Text('ยังไม่สแกน', style: TextStyle(color: kGrey)),
                onTap: () => _showRosterMenu(activity, item),
              ),
            ),
        ],
      ),
    );
  }

  Widget _numberCard(String label, int number) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$number', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: kGrey)),
            ],
          ),
        ),
      ),
    );
  }

  // กดที่ชื่อแล้วขึ้นเมนู ให้ชั่วโมง ยกเลิกชั่วโมง หรือลบออก
  void _showRosterMenu(Activity activity, RosterItem item) {
    final supProvider = context.read<SupervisorProvider>();

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(item.registration.studentName),
                subtitle: Text(item.registration.studentId),
              ),
              if (!item.hasCredit)
                ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text('ให้ ${hoursText(activity.hours)}'),
                  onTap: () {
                    supProvider.giveCredit(activity, item);
                    Navigator.pop(sheetContext);
                  },
                ),
              if (item.hasCredit)
                ListTile(
                  leading: const Icon(Icons.undo),
                  title: const Text('ยกเลิกชั่วโมง'),
                  onTap: () {
                    supProvider.removeCredit(activity, item);
                    Navigator.pop(sheetContext);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.person_remove_outlined, color: kRed),
                title: const Text('ลบออกจากรายชื่อ', style: TextStyle(color: kRed)),
                onTap: () {
                  supProvider.removeFromRoster(activity, item);
                  Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // เพิ่มนิสิตเอง เช่น มือถือนิสิตแบตหมด
  void _showAddDialog(Activity activity) {
    final formKey = GlobalKey<FormState>();
    final idController = TextEditingController();
    final nameController = TextEditingController();
    String? faculty;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('เพิ่มนิสิตและให้ชั่วโมง'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: idController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'รหัสนิสิต'),
                    validator: validateStudentId,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'ชื่อ นามสกุล'),
                    validator: validateRequired,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'คณะ'),
                    items: kFaculties.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                    onChanged: (value) => faculty = value,
                    validator: (value) => value == null ? 'กรุณาเลือกคณะ' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('ยกเลิก')),
            TextButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                await context.read<SupervisorProvider>().addStudentManually(
                      activity,
                      idController.text,
                      nameController.text,
                      faculty!,
                    );
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                _showMessage('เพิ่ม ${nameController.text} และให้ชั่วโมงแล้ว');
              },
              child: const Text('เพิ่ม'),
            ),
          ],
        );
      },
    );
  }

  // พิมพ์ประกาศ แล้วแจ้งเตือนทุกคนที่ลงทะเบียน
  void _showAnnounceDialog(Activity activity) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('ประกาศถึงผู้ลงทะเบียน'),
          content: TextField(
            controller: textController,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'เช่น ย้ายจุดนัดพบไปหน้าหอประชุม'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('ยกเลิก')),
            TextButton(
              onPressed: () async {
                if (textController.text.trim().isEmpty) return;
                final count = await context.read<SupervisorProvider>().postAnnouncement(
                      activity,
                      textController.text,
                    );
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                _showMessage('ส่งประกาศและแจ้งเตือน $count คนแล้ว');
              },
              child: const Text('ส่งประกาศ'),
            ),
          ],
        );
      },
    );
  }
}
