import 'package:flutter/material.dart';

import 'views/auth/sign_in_page.dart';
import 'views/auth/sign_up_page.dart';
import 'views/home/home_page.dart';
import 'views/chat/chat_screen.dart';
import 'views/profile/profile_page.dart';
import 'views/contacts/friend_invites_page.dart';
import 'views/search/global_search_page.dart';
import 'views/chat/chat_search_page.dart';
import 'views/contacts/add_friend_page.dart';
import 'views/contacts/add_friend_page.dart';
import 'views/contacts/create_group_page.dart';
import 'views/call/video_call_screen.dart';
import 'views/call/voice_call_screen.dart';
import 'views/chat/scheduled_messages_page.dart';
import 'views/chat/chat_settings_page.dart';
import 'views/splash/splash_page.dart';
import 'views/settings/edit_email_page.dart';
import 'views/settings/edit_phone_page.dart';
import 'views/settings/account_security_page.dart';
import 'views/settings/appearance_language_page.dart';
import 'views/settings/call_settings_page.dart';
import 'views/settings/chat_settings_global_page.dart';
import 'views/settings/notifications_settings_page.dart';
import 'views/settings/privacy_settings_page.dart';
import 'views/settings/settings_page.dart';

class AppRoutes {
  static const splash             = '/';
  static const signIn             = '/sign-in';
  static const signUp             = '/sign-up';
  static const home               = '/home';
  static const chat               = '/chat';
  static const profile            = '/profile';
  static const friendInvites      = '/friend-invites';
  static const search             = '/search';
  static const chatSearch         = '/chat-search';
  static const addFriend          = '/add-friend';
  static const createGroup        = '/create-group';
  static const voiceCall          = '/voice-call';
  static const videoCall          = '/video-call';
  static const scheduledMessages  = '/scheduled-messages';

  static const chatSettings       = '/chat-settings';
  static const accountSecurity    = '/account-security';
  static const editPhone          = '/edit-phone';
  static const editEmail          = '/edit-email';
  static const settings           = '/settings';
  static const privacySettings    = '/privacy-settings';
  static const notificationsSettings = '/notifications-settings';
  static const chatSettingsGlobal = '/chat-settings-global';
  static const callSettings       = '/call-settings';
  static const appearanceLanguage = '/appearance-language';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings s) {
    switch (s.name) {
      case AppRoutes.splash:
        return _material(s, const SplashPage());

      case AppRoutes.signIn:
        return _material(s, const SignInPage());

      case AppRoutes.signUp:
        return _material(s, const SignUpPage());

      case AppRoutes.home:
        return _material(s, const HomePage());

      case AppRoutes.chat: {
        final args = (s.arguments is Map) ? (s.arguments as Map) : const {};
        final conversationId = (args['conversationId'] as String?) ?? 'unknown';
        final title          = (args['title'] as String?) ?? 'Chat';
        return _material(s, ChatScreen(conversationId: conversationId, title: title));
      }

      case AppRoutes.profile: {
        final args = (s.arguments is Map) ? (s.arguments as Map) : const {};
        final userId = (args['userId'] as String?) ?? 'me';
        return _material(s, ProfilePage(userId: userId));
      }

      case AppRoutes.chatSearch:
        final a = (s.arguments as Map?) ?? const {};
        return MaterialPageRoute(
          builder: (_) => ChatSearchPage(
            conversationId: a['conversationId'] ?? 'unknown',
            title: a['title'] ?? 'Chat',
          ),
        );

      case AppRoutes.friendInvites:
        return _material(s, const FriendInvitesPage());

      case AppRoutes.search:
        return MaterialPageRoute(builder: (_) => const GlobalSearchPage());


      case AppRoutes.addFriend:
        return MaterialPageRoute(builder: (_) => const AddFriendPage());

      case AppRoutes.createGroup:
        return MaterialPageRoute(builder: (_) => const CreateGroupPage());

      case AppRoutes.voiceCall: {
        final a = (s.arguments as Map?) ?? const {};
        return _material(s, VoiceCallScreen(
          peerId: a['peerId'] as String? ?? 'unknown',
          peerName: a['peerName'] as String? ?? 'Người dùng',
          avatarUrl: a['avatarUrl'] as String?,
        ));
      }

      case AppRoutes.videoCall: {
        final a = (s.arguments as Map?) ?? const {};
        return _material(s, VideoCallScreen(
          peerId: a['peerId'] as String? ?? 'unknown',
          peerName: a['peerName'] as String? ?? 'Người dùng',
          avatarUrl: a['avatarUrl'] as String?,
        ));
      }

      case AppRoutes.scheduledMessages:
      return _material(s, const ScheduledMessagesPage());

      case AppRoutes.chatSettings: {
        final a = (s.arguments as Map?) ?? const {};
        return MaterialPageRoute(
          builder: (_) => ChatSettingsPage(
            conversationId: a['conversationId'] ?? 'unknown',
            title: a['title'] ?? 'Chat',
            avatarUrl: a['avatarUrl'] as String?,
            avatarText: a['avatarText'] as String?,
          ),
        );
      }

      case AppRoutes.accountSecurity:
        return _material(s, const AccountSecurityPage());

      case AppRoutes.editPhone:
        final a = (s.arguments as Map?) ?? const {};
        return _material(
          s,
          EditPhonePage(currentPhone: a['currentPhone'] as String?),
        );

      case AppRoutes.editEmail:
        final a = (s.arguments as Map?) ?? const {};
        return _material(
          s,
          EditEmailPage(currentEmail: a['currentEmail'] as String?),
        );

      case AppRoutes.settings:
        return _material(s, const SettingsPage());

      case AppRoutes.privacySettings:
        return _material(s, const PrivacySettingsPage());

      case AppRoutes.notificationsSettings:
        return _material(s, const NotificationsSettingsPage());

      case AppRoutes.chatSettingsGlobal:
        return _material(s, const ChatSettingsGlobalPage());

      case AppRoutes.callSettings:
        return _material(s, const CallSettingsPage());

      case AppRoutes.appearanceLanguage:
        return _material(s, const AppearanceLanguagePage());

      default:
        return _material(
          s,
          const Scaffold(
            body: Center(child: Text('404 • Route not found')),
          ),
        );
    }
  }

  // helper: luôn gắn settings để Navigator observers hoạt động đúng
  static MaterialPageRoute _material(RouteSettings s, Widget child) =>
      MaterialPageRoute(settings: s, builder: (_) => child);
}