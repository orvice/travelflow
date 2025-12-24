import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class ThemeProvider with ChangeNotifier {
  final ThemeService _themeService = ThemeService();

  Color _primaryColor = Colors.blue;
  ThemeMode _themeMode = ThemeMode.light;

  Color get primaryColor => _primaryColor;
  ThemeMode get themeMode => _themeMode;

  // 获取当前主题数据
  ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      brightness: Brightness.light,
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      brightness: Brightness.dark,
    );
  }

  // 加载保存的主题设置
  Future<void> loadTheme() async {
    _primaryColor = await _themeService.getThemeColorObject();
    _themeMode = await _themeService.getThemeMode();
    notifyListeners();
  }

  // 设置主题颜色
  Future<void> setThemeColor(String colorName) async {
    final color = ThemeService.themeColors[colorName];
    if (color != null) {
      _primaryColor = color;
      await _themeService.saveThemeColor(colorName);
      notifyListeners();
    }
  }

  // 设置主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _themeService.saveThemeMode(mode);
    notifyListeners();
  }

  // 获取当前颜色名称
  Future<String> getCurrentColorName() async {
    return await _themeService.getThemeColor();
  }

  // 获取所有可用颜色
  Map<String, Color> get availableColors => ThemeService.themeColors;
}
