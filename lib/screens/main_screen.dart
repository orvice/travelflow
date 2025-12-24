import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue.shade600,
          unselectedItemColor: Colors.grey.shade600,
          selectedLabelStyle: GoogleFonts.notoSansSc(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: GoogleFonts.notoSansSc(fontSize: 12),
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.flight_takeoff,
                color:
                    _currentIndex == 0
                        ? Colors.blue.shade600
                        : Colors.grey.shade600,
              ),
              label: '计划',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.history,
                color:
                    _currentIndex == 1
                        ? Colors.blue.shade600
                        : Colors.grey.shade600,
              ),
              label: '历史记录',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.settings,
                color:
                    _currentIndex == 2
                        ? Colors.blue.shade600
                        : Colors.grey.shade600,
              ),
              label: '设置',
            ),
          ],
        ),
      ),
    );
  }
}
