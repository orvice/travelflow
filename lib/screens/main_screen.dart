import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import '../providers/theme_provider.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final primaryColor = themeProvider.primaryColor;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.4),
              Colors.black.withValues(alpha: 0.2),
              Colors.transparent,
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.25),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white.withValues(alpha: 0.6),
            selectedLabelStyle: GoogleFonts.notoSansSc(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            unselectedLabelStyle: GoogleFonts.notoSansSc(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.6),
            ),
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  decoration: BoxDecoration(
                    color:
                        _currentIndex == 0
                            ? primaryColor.withValues(alpha: 0.3)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.flight_takeoff,
                    color:
                        _currentIndex == 0
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.6),
                    size: 22,
                  ),
                ),
                label: '计划',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  decoration: BoxDecoration(
                    color:
                        _currentIndex == 1
                            ? primaryColor.withValues(alpha: 0.3)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.history,
                    color:
                        _currentIndex == 1
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.6),
                    size: 22,
                  ),
                ),
                label: '历史记录',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  decoration: BoxDecoration(
                    color:
                        _currentIndex == 2
                            ? primaryColor.withValues(alpha: 0.3)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.settings,
                    color:
                        _currentIndex == 2
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.6),
                    size: 22,
                  ),
                ),
                label: '设置',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
