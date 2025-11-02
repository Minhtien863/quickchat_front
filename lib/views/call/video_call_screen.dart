import 'dart:async';
import 'package:flutter/material.dart';

class VideoCallScreen extends StatefulWidget {
  final String peerId;
  final String peerName;
  final String? avatarUrl;

  const VideoCallScreen({
    super.key,
    required this.peerId,
    required this.peerName,
    this.avatarUrl,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _muted = false;
  bool _cameraOn = true;
  bool _frontCam = true;
  bool _connected = false;
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Mock: sau 2s "kết nối"
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
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Remote video (mock) — nền mờ + tên
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: Center(
                  child: Text(
                    _connected ? widget.peerName : 'Đang gọi video…',
                    style: const TextStyle(color: Colors.white54, fontSize: 18),
                  ),
                ),
              ),
            ),

            // Local preview (mock)
            Positioned(
              right: 12, top: 12, width: 110, height: 160,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.person, color: Colors.white54, size: 40),
                ),
              ),
            ),

            // Top bar
            Positioned(
              left: 8, right: 8, top: 8,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 6),
                  Text(widget.peerName,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  if (_connected)
                    Text(_fmt(_elapsed), style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),

            // Controls bottom
            Positioned(
              left: 0, right: 0, bottom: 22,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ctrl(Icons.mic_off, active: _muted, onTap: () => setState(() => _muted = !_muted)),
                  _ctrl(_cameraOn ? Icons.videocam : Icons.videocam_off,
                      active: !_cameraOn, onTap: () => setState(() => _cameraOn = !_cameraOn)),
                  _ctrl(Icons.cameraswitch, onTap: () => setState(() => _frontCam = !_frontCam)),
                  _hangup(() => Navigator.pop(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ctrl(IconData icon, {bool active = false, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 64, height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? Colors.white24 : Colors.white12,
          border: active ? Border.all(color: Colors.white54) : null,
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _hangup(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 70, height: 70,
        decoration: const BoxDecoration(
            shape: BoxShape.circle, color: Colors.redAccent),
        child: const Icon(Icons.call_end, color: Colors.white, size: 30),
      ),
    );
  }
}
