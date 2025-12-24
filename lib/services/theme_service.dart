import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeColorKey = 'theme_color';
  static const String _themeModeKey = 'theme_mode';

  // 可选的主题颜色
  static final Map<String, Color> themeColors = {
    '蓝色': Colors.blue,
    '紫色': Colors.purple,
    '绿色': Colors.green,
    '橙色': Colors.orange,
    '红色': Colors.red,
    '粉色': Colors.pink,
    '青色': Colors.cyan,
    '黄色': Colors.yellow,
  };

  // 保存主题颜色
  Future<void> saveThemeColor(String colorName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeColorKey, colorName);
  }

  // 获取保存的主题颜色
  Future<String> getThemeColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeColorKey) ?? '蓝色';
  }

  // 保存主题模式（明亮/黑暗）
  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.toString());
  }

  // 获取保存的主题模式
  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(_themeModeKey);
    if (modeString == 'ThemeMode.dark') {
      return ThemeMode.dark;
    } else if (modeString == 'ThemeMode.light') {
      return ThemeMode.light;
    }
    return ThemeMode.system;
  }

  // 获取颜色对象
  Future<Color> getThemeColorObject() async {
    final colorName = await getThemeColor();
    return themeColors[colorName] ?? Colors.blue;
  }

  // 获取所有颜色名称
  List<String> getColorNames() {
    return themeColors.keys.toList();
  }
}
