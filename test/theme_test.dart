import 'package:flutter_test/flutter_test.dart';
import 'package:travelflow/services/theme_service.dart';
import 'package:travelflow/providers/theme_provider.dart';
import 'package:flutter/material.dart';

void main() {
  group('Theme Service Tests', () {
    test('ThemeService should have correct color options', () {
      final themeService = ThemeService();
      final colors = themeService.getColorNames();

      expect(colors.length, 8);
      expect(colors.contains('蓝色'), true);
      expect(colors.contains('紫色'), true);
      expect(colors.contains('绿色'), true);
      expect(colors.contains('橙色'), true);
      expect(colors.contains('红色'), true);
      expect(colors.contains('粉色'), true);
      expect(colors.contains('青色'), true);
      expect(colors.contains('黄色'), true);
    });

    test('ThemeService should return correct color objects', () {
      expect(ThemeService.themeColors['蓝色'], Colors.blue);
      expect(ThemeService.themeColors['紫色'], Colors.purple);
      expect(ThemeService.themeColors['绿色'], Colors.green);
      expect(ThemeService.themeColors['橙色'], Colors.orange);
      expect(ThemeService.themeColors['红色'], Colors.red);
      expect(ThemeService.themeColors['粉色'], Colors.pink);
      expect(ThemeService.themeColors['青色'], Colors.cyan);
      expect(ThemeService.themeColors['黄色'], Colors.yellow);
    });
  });

  group('Theme Provider Tests', () {
    test('ThemeProvider should initialize with default values', () {
      final provider = ThemeProvider();

      expect(provider.primaryColor, Colors.blue);
      expect(provider.themeMode, ThemeMode.light);
    });

    test('ThemeProvider should have correct theme data', () {
      final provider = ThemeProvider();

      final lightTheme = provider.lightTheme;
      final darkTheme = provider.darkTheme;

      expect(lightTheme.brightness, Brightness.light);
      expect(darkTheme.brightness, Brightness.dark);
    });
  });
}
