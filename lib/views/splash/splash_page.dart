import 'package:flutter/material.dart';

import '../../routes.dart';
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  // initState
  @override
  void initState() {
    super.initState();
    _goNext();
  }

  // _goNext
  Future<void> _goNext() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.signIn);
  }

  // build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFE5E7EB),
        alignment: Alignment.center,
        child: Image.asset(
          'assets/images/quickchat_splash.png',
          width: 220,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}