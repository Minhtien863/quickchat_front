import 'package:flutter/material.dart';

import '../../routes.dart';
import '../../widgets/q_app_header.dart'; // QAppHeader + AppSection

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

  final _pages = const [
    MessagesTab(),
    ContactsTab(),
    NotificationsTab(),
    MenuTab(),
  ];

  // Map chỉ số bottom bar -> AppSection cho header
  AppSection _sectionFromBottomIndex(int i) {
    switch (i) {
      case 0:
        return AppSection.messages;
      case 1:
        return AppSection.contacts;
      case 2:
        return AppSection.notifications;
      case 3:
        return AppSection.profile; // tương ứng tab "Menu/Cá nhân"
      default:
        return AppSection.messages;
    }
  }

  PreferredSizeWidget _buildAppBar() {
    // Tab THÔNG BÁO: header trắng, title lớn, không có search
    if (_index == 2) {
      return QAppHeader.plain(title: 'Thông báo');
    }

    // Các tab còn lại: header gradient + search toàn app (readOnly, chạm để mở trang Search)
    return QAppHeader.home(
      section: _sectionFromBottomIndex(_index),
      onTapSearch: () => Navigator.pushNamed(context, AppRoutes.search), // GLOBAL SEARCH
      onAddFriend: () => Navigator.pushNamed(context, AppRoutes.addFriend),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Tin nhắn',
          ),
          NavigationDestination(
            icon: Icon(Icons.contacts_outlined),
            selectedIcon: Icon(Icons.contacts),
            label: 'Danh bạ',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none),
            selectedIcon: Icon(Icons.notifications),
            label: 'Thông báo',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu),
            selectedIcon: Icon(Icons.menu_open),
            label: 'Menu',
          ),
        ],
      ),
    );
  }
}