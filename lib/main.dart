import 'package:flutter/material.dart';
import 'routes.dart';
import 'widgets/app_theme.dart';

import 'services/service_registry.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // khởi tạo AuthServiceHttp (load token + user từ storage)
  await Services.init();
  runApp(const QuickChatApp());
}

class QuickChatApp extends StatelessWidget {
  const QuickChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickChat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
