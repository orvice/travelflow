import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentColorName = '蓝色';
  ThemeMode _currentThemeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  Future<void> _loadCurrentSettings() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final colorName = await themeProvider.getCurrentColorName();
    setState(() {
      _currentColorName = colorName;
      _currentThemeMode = themeProvider.themeMode;
    });
  }

  void _showThemeColorDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            '选择主题颜色',
            style: GoogleFonts.notoSansSc(fontWeight: FontWeight.w600),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: themeProvider.availableColors.length,
              itemBuilder: (context, index) {
                final colorName = themeProvider.availableColors.keys.elementAt(
                  index,
                );
                final color = themeProvider.availableColors[colorName];
                final isSelected = colorName == _currentColorName;

                return ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  title: Text(
                    colorName,
                    style: GoogleFonts.notoSansSc(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  trailing:
                      isSelected
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                  onTap: () async {
                    await themeProvider.setThemeColor(colorName);
                    setState(() {
                      _currentColorName = colorName;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '主题颜色已更新',
                          style: GoogleFonts.notoSansSc(),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消', style: GoogleFonts.notoSansSc()),
            ),
          ],
        );
      },
    );
  }

  void _showThemeModeDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            '选择主题模式',
            style: GoogleFonts.notoSansSc(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.light_mode),
                title: Text('明亮模式', style: GoogleFonts.notoSansSc()),
                trailing:
                    _currentThemeMode == ThemeMode.light
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                onTap: () async {
                  await themeProvider.setThemeMode(ThemeMode.light);
                  setState(() {
                    _currentThemeMode = ThemeMode.light;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '已切换到明亮模式',
                        style: GoogleFonts.notoSansSc(),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: Text('黑暗模式', style: GoogleFonts.notoSansSc()),
                trailing:
                    _currentThemeMode == ThemeMode.dark
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                onTap: () async {
                  await themeProvider.setThemeMode(ThemeMode.dark);
                  setState(() {
                    _currentThemeMode = ThemeMode.dark;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '已切换到黑暗模式',
                        style: GoogleFonts.notoSansSc(),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.computer),
                title: Text('跟随系统', style: GoogleFonts.notoSansSc()),
                trailing:
                    _currentThemeMode == ThemeMode.system
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                onTap: () async {
                  await themeProvider.setThemeMode(ThemeMode.system);
                  setState(() {
                    _currentThemeMode = ThemeMode.system;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '已设置为跟随系统',
                        style: GoogleFonts.notoSansSc(),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消', style: GoogleFonts.notoSansSc()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorName = _currentColorName;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '设置',
          style: GoogleFonts.notoSansSc(fontWeight: FontWeight.w600),
        ),
        backgroundColor: themeProvider.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeProvider.primaryColor.withOpacity(0.1),
              themeProvider.primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 主题设置卡片
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      '主题设置',
                      style: GoogleFonts.notoSansSc(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.color_lens_outlined,
                      color: themeProvider.primaryColor,
                    ),
                    title: Text(
                      '主题颜色',
                      style: GoogleFonts.notoSansSc(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      colorName,
                      style: GoogleFonts.notoSansSc(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade400,
                    ),
                    onTap: _showThemeColorDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.dark_mode_outlined,
                      color: themeProvider.primaryColor,
                    ),
                    title: Text(
                      '主题模式',
                      style: GoogleFonts.notoSansSc(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      _getThemeModeText(_currentThemeMode),
                      style: GoogleFonts.notoSansSc(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade400,
                    ),
                    onTap: _showThemeModeDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 关于应用卡片
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.info_outline,
                  color: themeProvider.primaryColor,
                ),
                title: Text(
                  '关于 TravelFlow',
                  style: GoogleFonts.notoSansSc(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  '版本 1.0.0',
                  style: GoogleFonts.notoSansSc(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'TravelFlow',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2026 TravelFlow',
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        '智能旅行规划助手，让您的旅行更加轻松愉快。',
                        style: GoogleFonts.notoSansSc(),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.privacy_tip_outlined,
                  color: themeProvider.primaryColor,
                ),
                title: Text(
                  '隐私政策',
                  style: GoogleFonts.notoSansSc(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '隐私政策页面开发中...',
                        style: GoogleFonts.notoSansSc(),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.help_outline,
                  color: themeProvider.primaryColor,
                ),
                title: Text(
                  '使用帮助',
                  style: GoogleFonts.notoSansSc(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '使用帮助页面开发中...',
                        style: GoogleFonts.notoSansSc(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '明亮模式';
      case ThemeMode.dark:
        return '黑暗模式';
      case ThemeMode.system:
        return '跟随系统';
      default:
        return '未知';
    }
  }
}
