import 'package:flutter/material.dart';
import '../../widgets/q_app_header.dart';
import '../../services/service_registry.dart';
import '../../services/chat_service.dart';

class ScheduledMessagesPage extends StatefulWidget {
  const ScheduledMessagesPage({super.key});

  @override
  State<ScheduledMessagesPage> createState() => _ScheduledMessagesPageState();
}

class _ScheduledMessagesPageState extends State<ScheduledMessagesPage> {
  late Future<List<ScheduledMessageDTO>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = Services.chat.listScheduled();
    setState(() {});
  }

  Future<void> _reschedule(ScheduledMessageDTO s) async {
    final dt = await _pickDateTime(context, initial: s.scheduleAt);
    if (dt == null) return;
    await Services.chat.reschedule(s.id, dt);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã đổi thời gian gửi')),
    );
    _reload();
  }

  Future<void> _sendNow(ScheduledMessageDTO s) async {
    await Services.chat.sendNow(s.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã gửi ngay')),
    );
    _reload();
  }

  Future<void> _cancel(ScheduledMessageDTO s) async {
    await Services.chat.cancelScheduled(s.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã hủy hẹn giờ')),
    );
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppHeader.plain(
        title: 'Tin nhắn hẹn giờ',
        onBack: () => Navigator.pop(context),
      ),
      body: FutureBuilder<List<ScheduledMessageDTO>>(
        future: _future,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data ?? [];
          if (data.isEmpty) {
            return const Center(child: Text('Chưa có tin nhắn hẹn giờ'));
          }
          return ListView.separated(
            itemCount: data.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final s = data[i];
              return ListTile(
                leading: const Icon(Icons.schedule),
                title: Text(
                  s.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  _fmtFull(s.scheduleAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) {
                    switch (v) {
                      case 'sendNow':
                        _sendNow(s);
                        break;
                      case 'reschedule':
                        _reschedule(s);
                        break;
                      case 'cancel':
                        _cancel(s);
                        break;
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'sendNow', child: Text('Gửi ngay')),
                    PopupMenuItem(value: 'reschedule', child: Text('Đổi thời gian')),
                    PopupMenuItem(value: 'cancel', child: Text('Hủy')),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

String _pad2(int x) => x.toString().padLeft(2, '0');
String _fmtFull(DateTime t) =>
    '${_pad2(t.day)}/${_pad2(t.month)}/${t.year} • ${_pad2(t.hour)}:${_pad2(t.minute)}';

Future<DateTime?> _pickDateTime(BuildContext context, {DateTime? initial}) async {
  final now = DateTime.now();
  final firstDate = now;
  final initDate = initial ?? now.add(const Duration(minutes: 5));
  final d = await showDatePicker(
    context: context,
    initialDate: initDate,
    firstDate: firstDate,
    lastDate: now.add(const Duration(days: 365)),
  );
  if (d == null) return null;
  final t = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: initDate.hour, minute: initDate.minute),
  );
  if (t == null) return null;
  return DateTime(d.year, d.month, d.day, t.hour, t.minute);
}
