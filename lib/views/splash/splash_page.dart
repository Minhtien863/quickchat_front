import 'package:flutter/material.dart';
import '../../routes.dart';
import '../../services/service_registry.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _goNext();
  }

  Future<void> _goNext() async {
    final u = await Services.auth.currentUser();
    if (!mounted) return;
    if (u != null) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.signIn);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFE5E7EB),
        alignment: Alignment.center,
        child: Image.asset(
          'assets/images/quickchat_splash_2.png',
          width: 220,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
