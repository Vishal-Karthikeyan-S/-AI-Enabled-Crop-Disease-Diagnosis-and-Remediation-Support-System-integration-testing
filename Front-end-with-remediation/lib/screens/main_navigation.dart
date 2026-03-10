import 'package:flutter/material.dart';
import '../widgets/custom_nav_bar.dart';
import 'home_screen.dart';
import 'remedies_screen.dart';
import 'camera_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;

  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;

  // 5 screens: Home, Remedies, Camera (Scanner), History, Settings
  final List<Widget> _screens = [
    const HomeScreen(), // Index 0 - Home
    const RemediesScreen(), // Index 1 - Remedies
    const CameraScreen(embedded: true), // Index 2 - Camera/Scanner
    const HistoryScreen(), // Index 3 - History
    const SettingsScreen(), // Index 4 - Settings
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, _screens.length - 1);
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      extendBody: true,
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
