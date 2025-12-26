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
  String _currentLanguage = '中文';

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
      _currentLanguage = themeProvider.language;
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
                    if (!context.mounted) return;
                    setState(() {
                      _currentColorName = colorName;
                    });
                    Navigator.pop(context);
                    if (!context.mounted) return;
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
                  if (!context.mounted) return;
                  setState(() {
                    _currentThemeMode = ThemeMode.light;
                  });
                  Navigator.pop(context);
                  if (!context.mounted) return;
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
                  if (!context.mounted) return;
                  setState(() {
                    _currentThemeMode = ThemeMode.dark;
                  });
                  Navigator.pop(context);
                  if (!context.mounted) return;
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
                  if (!context.mounted) return;
                  setState(() {
                    _currentThemeMode = ThemeMode.system;
                  });
                  Navigator.pop(context);
                  if (!context.mounted) return;
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

  void _showLanguageDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            '选择语言',
            style: GoogleFonts.notoSansSc(fontWeight: FontWeight.w600),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: themeProvider.availableLanguages.length,
              itemBuilder: (context, index) {
                final languageName = themeProvider.availableLanguages[index];
                final isSelected = languageName == _currentLanguage;

                return ListTile(
                  title: Text(
                    languageName,
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
                    await themeProvider.setLanguage(languageName);
                    if (!context.mounted) return;
                    setState(() {
                      _currentLanguage = languageName;
                    });
                    Navigator.pop(context);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('语言已更新', style: GoogleFonts.notoSansSc()),
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

  // 辅助方法：构建设置项
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? value,
    required VoidCallback onTap,
    bool showChevron = false,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, size: 20),
        title: Text(
          title,
          style: GoogleFonts.notoSansSc(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle:
            value != null
                ? Text(
                  value,
                  style: GoogleFonts.notoSansSc(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )
                : null,
        trailing: showChevron ? Icon(Icons.chevron_right, size: 20) : null,
        onTap: onTap,
      ),
    );
  }

  // 辅助方法：构建分组标题
  Widget _buildGroupTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.notoSansSc(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // 使用 Material 3 风格的 AppBar
      appBar: AppBar(
        title: Text(
          '设置',
          style: GoogleFonts.notoSansSc(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: Container(
        // 使用当前主题的背景色
        color: colorScheme.surface,
        child: ListView(
          children: [
            // 主题设置
            _buildGroupTitle('主题设置', Icons.palette),
            _buildSettingItem(
              icon: Icons.color_lens,
              title: '主题颜色',
              value: _currentColorName,
              showChevron: true,
              onTap: _showThemeColorDialog,
            ),
            _buildSettingItem(
              icon: Icons.dark_mode,
              title: '主题模式',
              value:
                  _currentThemeMode == ThemeMode.light
                      ? '明亮模式'
                      : _currentThemeMode == ThemeMode.dark
                      ? '黑暗模式'
                      : '跟随系统',
              showChevron: true,
              onTap: _showThemeModeDialog,
            ),

            // 通用设置
            _buildGroupTitle('通用设置', Icons.settings),
            _buildSettingItem(
              icon: Icons.language,
              title: '语言',
              value: _currentLanguage,
              showChevron: true,
              onTap: _showLanguageDialog,
            ),

            // 应用信息
            _buildGroupTitle('关于', Icons.info),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TravelFlow',
                      style: GoogleFonts.notoSansSc(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '版本: 1.0.0',
                      style: GoogleFonts.notoSansSc(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '智能旅行规划助手',
                      style: GoogleFonts.notoSansSc(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
