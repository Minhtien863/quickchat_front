import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// Kết quả chọn lịch gửi
class ScheduleChoice {
  final DateTime? scheduledAt; // null nếu dùng whenOnline
  final bool whenOnline;
  ScheduleChoice({this.scheduledAt, required this.whenOnline});
}

/// Hiện bottom-sheet hẹn giờ.
/// [peerName] sẽ dùng cho menu "Gửi khi {peerName} trực tuyến".
Future<ScheduleChoice?> showScheduleSendSheet(
    BuildContext context, {
      required String draftText,
      required String peerName,
    }) {
  return showModalBottomSheet<ScheduleChoice>(
    context: context,
    useSafeArea: true,
    isScrollControlled: false,
    backgroundColor: Colors.transparent,
    builder: (_) => _ScheduleSheet(draftText: draftText, peerName: peerName),
  );
}

class _ScheduleSheet extends StatefulWidget {
  final String draftText;
  final String peerName;
  const _ScheduleSheet({required this.draftText, required this.peerName});

  @override
  State<_ScheduleSheet> createState() => _ScheduleSheetState();
}

class _ScheduleSheetState extends State<_ScheduleSheet> {
  late DateTime _base; // ngày hôm nay (00:00)
  int _dayIndex = 0;
  int _hour = 0;
  int _minute = 0;

  final _dayCtrl = FixedExtentScrollController();
  final _hCtrl   = FixedExtentScrollController();
  final _mCtrl   = FixedExtentScrollController();

  bool _sendWhenOnline = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final next = now.add(const Duration(minutes: 1));
    _base   = DateTime(next.year, next.month, next.day);
    _hour   = next.hour;
    _minute = next.minute;
    _hCtrl.jumpToItem(_hour);
    _mCtrl.jumpToItem(_minute);
  }

  @override
  void dispose() {
    _dayCtrl.dispose();
    _hCtrl.dispose();
    _mCtrl.dispose();
    super.dispose();
  }

  String _dayLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final delta = d.difference(today).inDays;
    if (delta == 0) return 'Hôm nay';
    if (delta == 1) return 'Ngày mai';
    const w = ['CN','Th 2','Th 3','Th 4','Th 5','Th 6','Th 7'];
    return '${w[d.weekday % 7]}, ${d.day}/${d.month}';
  }

  DateTime _selectedDateTime() {
    final date = _base.add(Duration(days: _dayIndex));
    return DateTime(date.year, date.month, date.day, _hour, _minute);
  }

  String _ctaText() {
    if (_sendWhenOnline) {
      return 'Gửi khi ${widget.peerName} trực tuyến';
    }
    final dt = _selectedDateTime();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final pickD = DateTime(dt.year, dt.month, dt.day);
    final prefix = pickD == today ? 'Gửi hôm nay lúc' : 'Gửi lúc';
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$prefix $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Selection overlay đẹp hơn & khoảng cách lớn hơn giữa các cột
    final selectionOverlay = Container(
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.primary.withOpacity(.25)),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
    );

    final pickerHeight = 172.0;
    const itemExtent = 40.0; // cao mỗi item (tăng so với trước)
    const gap = SizedBox(width: 14); // TĂNG KHOẢNG CÁCH giữa 3 picker

    final dt = _selectedDateTime();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            boxShadow: const [BoxShadow(blurRadius: 20, color: Colors.black26)],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header + menu
                Row(
                  children: [
                    const Expanded(
                      child: Text('Hẹn giờ gửi',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'Tuỳ chọn',
                      onSelected: (v) {
                        if (v == 'online') {
                          setState(() => _sendWhenOnline = true);
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'online',
                          child: Text('Gửi khi ${widget.peerName} trực tuyến'),
                        ),
                      ],
                      icon: const Icon(Icons.more_vert),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Preview bong bóng + dòng thời gian dự kiến
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer.withOpacity(.45),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(widget.draftText, style: const TextStyle(fontSize: 15)),
                      ),
                      Text(
                        _sendWhenOnline
                            ? 'Sẽ gửi khi ${widget.peerName} trực tuyến'
                            : 'Sẽ gửi lúc ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}',
                        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 3 Picker với khoảng cách lớn hơn
                IgnorePointer(
                  ignoring: _sendWhenOnline, // nếu chọn "khi online" thì vô hiệu hoá picker
                  child: Opacity(
                    opacity: _sendWhenOnline ? .45 : 1,
                    child: SizedBox(
                      height: pickerHeight,
                      child: Row(
                        children: [
                          // Day
                          Expanded(
                            flex: 5,
                            child: CupertinoPicker(
                              selectionOverlay: selectionOverlay,
                              scrollController: _dayCtrl,
                              itemExtent: itemExtent,
                              magnification: 1.05,
                              squeeze: 1.15,
                              useMagnifier: true,
                              onSelectedItemChanged: (i) => setState(() => _dayIndex = i),
                              children: List.generate(14, (i) {
                                final d = _base.add(Duration(days: i));
                                return Center(child: Text(_dayLabel(d)));
                              }),
                            ),
                          ),
                          gap,
                          // Hour
                          Expanded(
                            flex: 3,
                            child: CupertinoPicker(
                              selectionOverlay: selectionOverlay,
                              scrollController: _hCtrl,
                              itemExtent: itemExtent,
                              magnification: 1.08,
                              squeeze: 1.15,
                              useMagnifier: true,
                              onSelectedItemChanged: (i) => setState(() => _hour = i),
                              children: List.generate(24,
                                      (i) => Center(child: Text(i.toString().padLeft(2, '0')))),
                            ),
                          ),
                          gap,
                          // Minute
                          Expanded(
                            flex: 3,
                            child: CupertinoPicker(
                              selectionOverlay: selectionOverlay,
                              scrollController: _mCtrl,
                              itemExtent: itemExtent,
                              magnification: 1.08,
                              squeeze: 1.15,
                              useMagnifier: true,
                              onSelectedItemChanged: (i) => setState(() => _minute = i),
                              children: List.generate(60,
                                      (i) => Center(child: Text(i.toString().padLeft(2, '0')))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // CTA
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (_sendWhenOnline) {
                        Navigator.pop(context, ScheduleChoice(scheduledAt: null, whenOnline: true));
                      } else {
                        Navigator.pop(context, ScheduleChoice(
                          scheduledAt: _selectedDateTime(),
                          whenOnline: false,
                        ));
                      }
                    },
                    child: Text(_ctaText(),
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
