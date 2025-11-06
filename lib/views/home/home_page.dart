import 'package:flutter/material.dart';

import '../../routes.dart';
import '../../widgets/q_app_header.dart';
import 'tabs/messages_tab.dart';
import 'tabs/contacts_tab.dart';
import 'tabs/notifications_tab.dart';
import 'tabs/menu_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  AppSection get _section {
    switch (_index) {
      case 0:
        return AppSection.messages;
      case 1:
        return AppSection.contacts;
      case 2:
        return AppSection.notifications;
      case 3:
        return AppSection.profile;
      default:
        return AppSection.messages;
    }
  }

  // Đổi tab bottom nav.
  void _onTapNav(int i) {
    setState(() => _index = i);
  }

  // Mở trang search chung.
  void _openSearch() {
    Navigator.pushNamed(context, AppRoutes.search);
  }

  // Mở thêm bạn.
  void _openAddFriend() {
    Navigator.pushNamed(context, AppRoutes.addFriend);
  }

  // Tạo chat mới (mock).
  void _openNewChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tạo cuộc trò chuyện mới (mock)')),
    );
  }

  // Mở trang cài đặt chính.
  void _openSettings() {
    Navigator.pushNamed(context, AppRoutes.settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppHeader.home(
        section: _section,
        onTapSearch: _openSearch,
        onAddFriend: _openAddFriend,
        onNewChat: _openNewChat,
        onSettings: _openSettings,
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          MessagesTab(),
          ContactsTab(),
          NotificationsTab(),
          MenuTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _onTapNav,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Tin nhắn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Danh bạ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: 'Thông báo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
      ),
    );
  }
}
