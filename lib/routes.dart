import 'package:flutter/material.dart';
import 'views/auth/sign_in_page.dart';
import 'views/auth/sign_up_page.dart';
import 'views/home/home_page.dart';
import 'views/chat/chat_screen.dart';
import 'views/profile/profile_page.dart';
import 'views/contacts/friend_invites_page.dart';

class AppRoutes {
  static const splash = '/';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const home   = '/home';
  static const chat   = '/chat';
  static const profile = '/profile';
  static const friendInvites = '/friend-invites';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings s) {
    switch (s.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const _SplashGate());
      case AppRoutes.signIn:
        return MaterialPageRoute(builder: (_) => const SignInPage());
      case AppRoutes.signUp:
        return MaterialPageRoute(builder: (_) => const SignUpPage());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case AppRoutes.chat:
        final args = (s.arguments as Map?) ?? {};
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: args['conversationId'] ?? 'unknown',
            title: args['title'] ?? 'Chat',
          ),
        );
      case AppRoutes.profile:
        final args = (s.arguments as Map?) ?? {};
        final userId = args['userId'] as String? ?? 'me';
        return MaterialPageRoute(builder: (_) => ProfilePage(userId: userId));
      case AppRoutes.friendInvites:
        return MaterialPageRoute(builder: (_) => const FriendInvitesPage());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('404 Not Found'))),
        );
    }
  }
}

class _SplashGate extends StatefulWidget {
  const _SplashGate();

  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // TODO: kiểm tra token/refresh → nếu hợp lệ thì vào home
      Navigator.of(context).pushReplacementNamed(AppRoutes.signIn);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
