import 'package:flutter/material.dart';

import 'message_boards/message_boards_screen.dart';
import 'profile/profile_screen.dart';
import 'settings/settings_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  final _pages = const [
    MessageBoardsScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  final _titles = const [
    'Message Boards',
    'Profile',
    'Settings',
  ];

  void _selectPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.of(context).pop(); // close the drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              const ListTile(
                leading: CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text('Message Board App'),
                subtitle: Text('Navigation'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.forum_outlined),
                title: const Text('Message Boards'),
                selected: _selectedIndex == 0,
                onTap: () => _selectPage(0),
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Profile'),
                selected: _selectedIndex == 1,
                onTap: () => _selectPage(1),
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                selected: _selectedIndex == 2,
                onTap: () => _selectPage(2),
              ),
            ],
          ),
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}