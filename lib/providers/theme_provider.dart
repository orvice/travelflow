import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class ThemeProvider with ChangeNotifier {
  final ThemeService _themeService = ThemeService();

  Color _primaryColor = Colors.blue;
  ThemeMode _themeMode = ThemeMode.light;
  String _language = '中文';

  Color get primaryColor => _primaryColor;
  ThemeMode get themeMode => _themeMode;
  String get language => _language;

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
    _language = await _themeService.getLanguage();
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

  // 设置语言
  Future<void> setLanguage(String language) async {
    _language = language;
    await _themeService.saveLanguage(language);
    notifyListeners();
  }

  // 获取API语言代码
  Future<String> getApiLanguage() async {
    return await _themeService.getApiLanguage();
  }

  // 获取所有可用颜色
  Map<String, Color> get availableColors => ThemeService.themeColors;

  // 获取所有可用语言
  List<String> get availableLanguages => ThemeService().getLanguageNames();
}
