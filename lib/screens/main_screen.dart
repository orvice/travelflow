import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'map_screen.dart';
import 'settings_screen.dart';
import '../providers/theme_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MapScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final primaryColor = themeProvider.primaryColor;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAnimatedTabButton(
                  index: 0,
                  icon: Icons.flight_takeoff,
                  label: '计划',
                  primaryColor: primaryColor,
                ),
                _buildAnimatedTabButton(
                  index: 1,
                  icon: Icons.map,
                  label: '地图',
                  primaryColor: primaryColor,
                ),
                _buildAnimatedTabButton(
                  index: 2,
                  icon: Icons.history,
                  label: '历史记录',
                  primaryColor: primaryColor,
                ),
                _buildAnimatedTabButton(
                  index: 3,
                  icon: Icons.settings,
                  label: '设置',
                  primaryColor: primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTabButton({
    required int index,
    required IconData icon,
    required String label,
    required Color primaryColor,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? primaryColor.withValues(alpha: 0.3)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border:
              isSelected
                  ? Border.all(
                    color: primaryColor.withValues(alpha: 0.5),
                    width: 1,
                  )
                  : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: Icon(
                  key: ValueKey('$index-icon'),
                  icon,
                  color:
                      isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.6),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.notoSansSc(
                fontSize: isSelected ? 11 : 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color:
                    isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.6),
                shadows:
                    isSelected
                        ? [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ]
                        : [],
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
