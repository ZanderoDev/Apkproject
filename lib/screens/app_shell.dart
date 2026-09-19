import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'attendance_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'members_screen.dart';
import 'settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _pages = [
    HomeScreen(),
    AttendanceScreen(),
    MembersScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.crimson.withOpacity(.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            selectedIcon: Icon(Icons.grid_view_rounded, color: AppTheme.crimson),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.how_to_reg_rounded),
            selectedIcon: Icon(Icons.how_to_reg_rounded, color: AppTheme.crimson),
            label: 'Absensi',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_rounded),
            selectedIcon: Icon(Icons.groups_rounded, color: AppTheme.crimson),
            label: 'Anggota',
          ),
          NavigationDestination(
            icon: Icon(Icons.timeline_rounded),
            selectedIcon: Icon(Icons.timeline_rounded, color: AppTheme.crimson),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded, color: AppTheme.crimson),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}
