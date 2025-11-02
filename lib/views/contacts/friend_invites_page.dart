import 'package:flutter/material.dart';

import '../../widgets/q_app_header.dart';
import '../../widgets/tokens.dart';
import '../../services/service_registry.dart';
import '../../services/contacts_service.dart';

class FriendInvitesPage extends StatefulWidget {
  const FriendInvitesPage({super.key});

  @override
  State<FriendInvitesPage> createState() => _FriendInvitesPageState();
}

class _FriendInvitesPageState extends State<FriendInvitesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  late Future<List<FriendInviteDTO>> _receivedFut;
  late Future<List<FriendInviteDTO>> _sentFut;

  // track loading theo từng nút
  final _busy = <String, bool>{};

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _reload();
  }

  void _reload() {
    _receivedFut = Services.contacts.listFriendInvites();
    _sentFut = Services.contacts.listSentFriendInvites();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  String _timeAgoShort(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inDays >= 1) return '${d.inDays} ngày trước';
    if (d.inHours >= 1) return '${d.inHours} giờ trước';
    if (d.inMinutes >= 1) return '${d.inMinutes} phút trước';
    return 'vừa xong';
  }

  // ---------------- RECIEVED ITEM — CARD NHỎ ----------------
  Widget _receivedCard(FriendInviteDTO iv) {
    final cs = Theme.of(context).colorScheme;
    final isBusyAccept  = _busy['acc_${iv.id}'] == true;
    final isBusyDecline = _busy['dec_${iv.id}'] == true;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.md),
        side: BorderSide(color: cs.outline.withOpacity(.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: cs.primaryContainer.withOpacity(.35),
              child: Text(
                (iv.displayName.isNotEmpty ? iv.displayName.characters.first : '?')
                    .toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.w700, color: cs.primary),
              ),
            ),
            const SizedBox(width: 10),

            // info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(iv.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('Muốn kết bạn',
                      style: TextStyle(fontSize: 13, color: cs.onSurface.withOpacity(.65))),
                  const SizedBox(height: 2),
                  Text(_timeAgoShort(iv.createdAt),
                      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant.withOpacity(.8))),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // buttons dọc, căn giữa theo chiều dọc
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _pillAgreeSmall(
                  context,
                  label: 'ĐỒNG Ý',
                  loading: isBusyAccept,
                  onPressed: isBusyAccept
                      ? null
                      : () async {
                    setState(() => _busy['acc_${iv.id}'] = true);
                    try {
                      await Services.contacts.acceptFriendInvite(iv.id);
                      setState(_reload);
                    } finally {
                      if (mounted) setState(() => _busy['acc_${iv.id}'] = false);
                    }
                  },
                ),
                const SizedBox(height: 8),
                _pillDeclineSmall(
                  context,
                  label: 'TỪ CHỐI',
                  loading: isBusyDecline,
                  onPressed: isBusyDecline
                      ? null
                      : () async {
                    setState(() => _busy['dec_${iv.id}'] = true);
                    try {
                      await Services.contacts.declineFriendInvite(iv.id);
                      setState(_reload);
                    } finally {
                      if (mounted) setState(() => _busy['dec_${iv.id}'] = false);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- SENT ITEM — CARD NHỎ ----------------
  Widget _sentCard(FriendInviteDTO iv) {
    final cs = Theme.of(context).colorScheme;
    final isBusy = _busy['cancel_${iv.id}'] == true;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.sm),
        side: BorderSide(color: cs.outline.withOpacity(.30)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 62),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: cs.primaryContainer.withOpacity(.35),
                child: Text(
                  (iv.displayName.isNotEmpty
                      ? iv.displayName.characters.first
                      : '?')
                      .toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // text
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      iv.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text('Muốn kết bạn',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: cs.onSurface.withOpacity(.65),
                        )),
                    const SizedBox(height: 2),
                    Text(
                      _timeAgoShort(iv.createdAt),
                      style: TextStyle(
                        fontSize: 11.5,
                        color: cs.onSurfaceVariant.withOpacity(.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              // nút THU HỒI — nhỏ, canh giữa theo chiều dọc
              Align(
                alignment: Alignment.centerRight,
                child: _pillDeclineSmall( // giữ style outline dịu cho THU HỒI
                  context,
                  label: 'THU HỒI',
                  loading: isBusy,
                  onPressed: isBusy
                      ? null
                      : () async {
                    setState(() => _busy['cancel_${iv.id}'] = true);
                    try {
                      await Services.contacts.cancelSentFriendInvite(iv.id);
                      setState(_reload);
                    } finally {
                      if (mounted) {
                        setState(() => _busy['cancel_${iv.id}'] = false);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: QAppHeader.plain(
        title: 'Lời mời kết bạn',
        onBack: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          // Tab gọn
          Container(
            margin: const EdgeInsets.fromLTRB(10, 8, 10, 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Radii.sm),
              border: Border.all(color: cs.outline.withOpacity(.30)),
            ),
            child: TabBar(
              controller: _tab,
              indicatorSize: TabBarIndicatorSize.tab,
              splashBorderRadius: BorderRadius.circular(Radii.sm),
              labelPadding: const EdgeInsets.symmetric(vertical: 8),
              tabs: const [Text('Đã nhận'), Text('Đã gửi')],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                // -------- Đã nhận --------
                FutureBuilder<List<FriendInviteDTO>>(
                  future: _receivedFut,
                  builder: (_, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final data = snap.data ?? [];
                    if (data.isEmpty) {
                      return const Center(child: Text('Không có lời mời nào'));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 8),
                      itemCount: data.length,
                      itemBuilder: (_, i) => _receivedCard(data[i]),
                    );
                  },
                ),

                // -------- Đã gửi --------
                FutureBuilder<List<FriendInviteDTO>>(
                  future: _sentFut,
                  builder: (_, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final data = snap.data ?? [];
                    if (data.isEmpty) {
                      return const Center(child: Text('Chưa gửi lời mời nào'));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 8),
                      itemCount: data.length,
                      itemBuilder: (_, i) => _sentCard(data[i]),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ===================== Tiny UI helpers ===================== */

// Nút đồng ý – nổi bật (primary), kích thước cố định để đều nhau
Widget _pillAgreeSmall(
    BuildContext context, {
      required String label,
      required VoidCallback? onPressed,
      bool loading = false,
    }) {
  final cs = Theme.of(context).colorScheme;
  return FilledButton(
    onPressed: loading ? null : onPressed,
    style: FilledButton.styleFrom(
      visualDensity: VisualDensity.compact,
      minimumSize: const Size(112, 32), // cố định
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      shape: const StadiumBorder(),
      backgroundColor: cs.primary,
      foregroundColor: cs.onPrimary,
      disabledBackgroundColor: cs.primary.withOpacity(.45),
      disabledForegroundColor: cs.onPrimary.withOpacity(.7),
    ),
    child: loading
        ? const SizedBox(width: 12, height: 12,
        child: CircularProgressIndicator(strokeWidth: 2))
        : Text(label),
  );
}

// Nút từ chối/thu hồi – outlined + nền dịu, kích thước cố định
Widget _pillDeclineSmall(
    BuildContext context, {
      required String label,
      required VoidCallback? onPressed,
      bool loading = false,
    }) {
  final cs = Theme.of(context).colorScheme;
  final softBg = Color.alphaBlend(cs.surfaceVariant.withOpacity(.18), cs.surface);
  return OutlinedButton(
    onPressed: loading ? null : onPressed,
    style: OutlinedButton.styleFrom(
      visualDensity: VisualDensity.compact,
      minimumSize: const Size(112, 32), // cố định
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      shape: const StadiumBorder(),
      side: BorderSide(color: cs.outlineVariant.withOpacity(.7), width: 1),
      backgroundColor: softBg,
      foregroundColor: cs.onSurface.withOpacity(.9),
      disabledForegroundColor: cs.onSurface.withOpacity(.45),
      disabledBackgroundColor:
      Color.alphaBlend(cs.surfaceVariant.withOpacity(.12), cs.surface),
    ),
    child: loading
        ? const SizedBox(width: 12, height: 12,
        child: CircularProgressIndicator(strokeWidth: 2))
        : Text(label),
  );
}
