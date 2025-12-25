import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/wallpaper_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentColorName = '蓝色';
  ThemeMode _currentThemeMode = ThemeMode.light;
  String? _wallpaperPath;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
    _loadWallpaper();
  }

  // 加载壁纸
  Future<void> _loadWallpaper() async {
    try {
      final wallpaperService = WallpaperService();
      final cachedPath = await wallpaperService.getCachedWallpaper();

      if (cachedPath != null && mounted) {
        setState(() {
          _wallpaperPath = cachedPath;
        });
      }
    } catch (e) {
      // 壁纸加载失败，保持默认背景
    }
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

  // 辅助方法：构建设置项
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? value,
    required VoidCallback onTap,
    bool showChevron = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.white,
          size: 20,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        title: Text(
          title,
          style: GoogleFonts.notoSansSc(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        subtitle:
            value != null
                ? Text(
                  value,
                  style: GoogleFonts.notoSansSc(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 1,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                )
                : null,
        trailing:
            showChevron
                ? Icon(
                  Icons.chevron_right,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 20,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 1,
                      offset: const Offset(0, 1),
                    ),
                  ],
                )
                : null,
        onTap: onTap,
      ),
    );
  }

  // 辅助方法：构建分组标题
  Widget _buildGroupTitle(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.notoSansSc(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorName = _currentColorName;
    final primaryColor = themeProvider.primaryColor;

    return Scaffold(
      // 移除传统 AppBar，使用自定义标题栏
      body: Stack(
        children: [
          // 壁纸背景
          if (_wallpaperPath != null)
            Positioned.fill(
              child: Image.file(
                File(_wallpaperPath!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // 如果图片加载失败，显示渐变背景
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primaryColor.withValues(alpha: 0.1),
                          primaryColor.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          else
            // 默认渐变背景
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor.withValues(alpha: 0.1),
                      primaryColor.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),

          // 半透明遮罩层，优化内容可读性（降低透明度）
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.15),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // 自定义标题栏（融入背景）- 降低透明度
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
                child: Row(
                  children: [
                    // 返回按钮
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 8),
                    // 标题
                    Text(
                      '设置',
                      style: GoogleFonts.notoSansSc(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 内容区域
          Positioned.fill(
            top: 90, // 增加顶部间距，为标题栏留出更多空间
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 8), // 顶部额外间距
                  // 主题设置卡片 - 半透明玻璃效果（提高透明度）
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGroupTitle('主题设置', Icons.color_lens),

                        // 主题颜色
                        _buildSettingItem(
                          icon: Icons.color_lens_outlined,
                          title: '主题颜色',
                          value: colorName,
                          onTap: _showThemeColorDialog,
                          showChevron: true,
                        ),

                        // 主题模式
                        _buildSettingItem(
                          icon: Icons.dark_mode_outlined,
                          title: '主题模式',
                          value: _getThemeModeText(_currentThemeMode),
                          onTap: _showThemeModeDialog,
                          showChevron: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 关于应用卡片 - 半透明玻璃效果（提高透明度）
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGroupTitle('关于应用', Icons.info),

                        // 关于 TravelFlow
                        _buildSettingItem(
                          icon: Icons.info_outline,
                          title: '关于 TravelFlow',
                          value: 'v1.0.0',
                          onTap: () {
                            showAboutDialog(
                              context: context,
                              barrierColor: Colors.black.withValues(alpha: 0.6),
                              applicationName: 'TravelFlow',
                              applicationVersion: '1.0.0',
                              applicationLegalese: '© 2026 TravelFlow',
                              children: [
                                const SizedBox(height: 16),
                                Text(
                                  '智能旅行规划助手，让您的旅行更加轻松愉快。',
                                  style: GoogleFonts.notoSansSc(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        // 隐私政策
                        _buildSettingItem(
                          icon: Icons.privacy_tip_outlined,
                          title: '隐私政策',
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

                        // 使用帮助
                        _buildSettingItem(
                          icon: Icons.help_outline,
                          title: '使用帮助',
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
                          showChevron: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
    }
  }
}
