import 'dart:async';
import 'package:flutter/material.dart';

class VoiceCallScreen extends StatefulWidget {
  final String peerId;
  final String peerName;
  final String? avatarUrl;

  const VoiceCallScreen({
    super.key,
    required this.peerId,
    required this.peerName,
    this.avatarUrl,
  });

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  bool _muted = false;
  bool _speakerOn = true;
  bool _connected = false;
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Mock: 2s sau coi như "đã kết nối" và bắt đầu đếm giờ
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _connected = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _elapsed += const Duration(seconds: 1));
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    final two = (int x) => x.toString().padLeft(2, '0');
    return h > 0 ? '${two(h)}:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
  }

  @override
  Widget build(BuildContext context) {
    final title = _connected ? _fmt(_elapsed) : 'Đang gọi…';
    return Scaffold(
      backgroundColor: const Color(0xFF0A84FF),
      body: SafeArea(
        child: Stack(
          children: [
            // Center info
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundImage:
                    (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty)
                        ? NetworkImage(widget.avatarUrl!)
                        : null,
                    child: (widget.avatarUrl == null || widget.avatarUrl!.isEmpty)
                        ? Text(widget.peerName.characters.first.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 28, color: Colors.white))
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(widget.peerName,
                      style: const TextStyle(
                          fontSize: 22, color: Colors.white, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(title, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),

            // Controls
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _roundBtn(
                      icon: _muted ? Icons.mic_off : Icons.mic,
                      label: _muted ? 'Bật mic' : 'Tắt mic',
                      onTap: () => setState(() => _muted = !_muted),
                    ),
                    _roundBtn(
                      icon: _speakerOn ? Icons.volume_up : Icons.hearing,
                      label: _speakerOn ? 'Loa ngoài' : 'Tai nghe',
                      onTap: () => setState(() => _speakerOn = !_speakerOn),
                    ),
                    _hangupBtn(onTap: () => Navigator.pop(context)),
                  ],
                ),
              ),
            ),

            // Back
            Positioned(
              left: 8,
              top: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roundBtn({required IconData icon, required String label, required VoidCallback onTap}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 64, height: 64,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Colors.white24),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }

  Widget _hangupBtn({required VoidCallback onTap}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 70, height: 70,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Colors.redAccent),
            child: const Icon(Icons.call_end, color: Colors.white, size: 30),
          ),
        ),
        const SizedBox(height: 6),
        const Text('Kết thúc', style: TextStyle(color: Colors.white70)),
      ],
    );
  }
}
