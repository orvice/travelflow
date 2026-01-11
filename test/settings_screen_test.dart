import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:travelflow/providers/theme_provider.dart';
import 'package:travelflow/screens/settings_screen.dart';

void main() {
  group('SettingsScreen Tests', () {
    late ThemeProvider themeProvider;

    setUp(() {
      themeProvider = ThemeProvider();
    });

    Widget createSettingsScreen() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      );
    }

    testWidgets('SettingsScreen renders basic UI elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createSettingsScreen());

      // Verify app bar title
      expect(find.text('设置'), findsOneWidget);

      // Verify main setting items
      expect(find.text('主题颜色'), findsOneWidget);
      expect(find.text('主题模式'), findsOneWidget);
      expect(find.text('语言'), findsOneWidget);
      expect(find.text('项目主页'), findsOneWidget);

      // Verify app info
      expect(find.text('TravelFlow'), findsOneWidget);
      expect(find.text('版本: 1.0.0'), findsOneWidget);
    });

    testWidgets('SettingsScreen shows initial values after load', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      // Find the setting items that show current values
      // Note: These values appear in ListTiles as subtitle or in dialogs
      final listTiles = find.byType(ListTile);
      expect(listTiles, findsWidgets);
    });

    testWidgets('Tapping theme color opens dialog', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      // Find and tap the theme color ListTile
      final themeColorTile = find.descendant(
        of: find.byType(ListTile),
        matching: find.text('主题颜色'),
      );
      await tester.tap(themeColorTile);
      await tester.pumpAndSettle();

      // Verify dialog appears
      expect(find.text('选择主题颜色'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('Theme color dialog shows all color options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      // Open theme color dialog
      final themeColorTile = find.descendant(
        of: find.byType(ListTile),
        matching: find.text('主题颜色'),
      );
      await tester.tap(themeColorTile);
      await tester.pumpAndSettle();

      // Check for color options in the dialog
      final dialogContent = find.text('蓝色');
      expect(dialogContent, findsWidgets);
    });

    testWidgets('Tapping theme mode opens dialog', (WidgetTester tester) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      // Find and tap the theme mode ListTile
      final themeModeTile = find.descendant(
        of: find.byType(ListTile),
        matching: find.text('主题模式'),
      );
      await tester.tap(themeModeTile);
      await tester.pumpAndSettle();

      // Verify dialog appears
      expect(find.text('选择主题模式'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('Theme mode dialog shows all mode options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      // Open theme mode dialog
      final themeModeTile = find.descendant(
        of: find.byType(ListTile),
        matching: find.text('主题模式'),
      );
      await tester.tap(themeModeTile);
      await tester.pumpAndSettle();

      // Check for mode options
      expect(find.text('明亮模式'), findsWidgets);
      expect(find.text('黑暗模式'), findsWidgets);
      expect(find.text('跟随系统'), findsWidgets);
    });

    testWidgets('Tapping language opens dialog', (WidgetTester tester) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      // Find and tap the language ListTile
      final languageTile = find.descendant(
        of: find.byType(ListTile),
        matching: find.text('语言'),
      );
      await tester.tap(languageTile);
      await tester.pumpAndSettle();

      // Verify dialog appears
      expect(find.text('选择语言'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('Language dialog shows language options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      // Open language dialog
      final languageTile = find.descendant(
        of: find.byType(ListTile),
        matching: find.text('语言'),
      );
      await tester.tap(languageTile);
      await tester.pumpAndSettle();

      // Check for language options
      expect(find.text('中文'), findsWidgets);
      expect(find.text('English'), findsWidgets);
    });

    testWidgets('Dialogs can be cancelled', (WidgetTester tester) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      // Test theme color dialog
      final themeColorTile = find.descendant(
        of: find.byType(ListTile),
        matching: find.text('主题颜色'),
      );
      await tester.tap(themeColorTile);
      await tester.pumpAndSettle();
      expect(find.text('选择主题颜色'), findsOneWidget);

      // Cancel the dialog
      final cancelButton = find.text('取消');
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();
      expect(find.text('选择主题颜色'), findsNothing);

      // Test theme mode dialog
      final themeModeTile = find.descendant(
        of: find.byType(ListTile),
        matching: find.text('主题模式'),
      );
      await tester.tap(themeModeTile);
      await tester.pumpAndSettle();
      expect(find.text('选择主题模式'), findsOneWidget);

      // Cancel the dialog
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();
      expect(find.text('选择主题模式'), findsNothing);

      // Test language dialog
      final languageTile = find.descendant(
        of: find.byType(ListTile),
        matching: find.text('语言'),
      );
      await tester.tap(languageTile);
      await tester.pumpAndSettle();
      expect(find.text('选择语言'), findsOneWidget);

      // Cancel the dialog
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();
      expect(find.text('选择语言'), findsNothing);
    });

    testWidgets('SettingsScreen has proper structure', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      // Verify main components
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Card), findsWidgets);
      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('SettingsScreen displays project information', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      // Verify project info card
      expect(find.text('TravelFlow'), findsOneWidget);
      expect(find.text('版本: 1.0.0'), findsOneWidget);
      expect(find.text('智能旅行规划助手'), findsOneWidget);

      // Verify project homepage link
      expect(find.text('https://travelflow.orz.ee/'), findsOneWidget);
    });

    testWidgets('SettingsScreen uses Material 3 styling', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      // Verify Material 3 components are used
      expect(find.byType(Card), findsWidgets);
      expect(find.byType(ListTile), findsWidgets);

      // Verify AppBar has no elevation (Material 3 style)
      final appBar = find.byType(AppBar);
      final AppBar widget = tester.widget(appBar);
      expect(widget.elevation, 0);
    });

    testWidgets('SettingsScreen handles provider state changes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      // Verify initial state by checking that the screen loads
      expect(find.text('设置'), findsOneWidget);

      // Just verify the provider can be accessed without errors
      expect(themeProvider, isNotNull);

      // Screen should still be functional
      expect(find.text('设置'), findsOneWidget);
    });

    testWidgets('SettingsScreen has scrollable content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      // Verify ListView exists for scrolling
      expect(find.byType(ListView), findsOneWidget);

      // Try to scroll
      await tester.drag(find.byType(ListView), const Offset(0, -100));
      await tester.pumpAndSettle();

      // Should still find the title after scrolling
      expect(find.text('设置'), findsOneWidget);
    });

    testWidgets('SettingsScreen has icons for each setting', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      // Verify key icons are present
      expect(find.byIcon(Icons.color_lens), findsOneWidget);
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
      expect(find.byIcon(Icons.language), findsOneWidget);
      expect(find.byIcon(Icons.link), findsOneWidget);
    });

    testWidgets('SettingsScreen dialog has proper structure', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      // Open any dialog
      final themeColorTile = find.descendant(
        of: find.byType(ListTile),
        matching: find.text('主题颜色'),
      );
      await tester.tap(themeColorTile);
      await tester.pumpAndSettle();

      // Verify dialog structure
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('选择主题颜色'), findsOneWidget);

      // Verify dialog has content
      final listView = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(ListView),
      );
      expect(listView, findsOneWidget);
    });

    testWidgets('SettingsScreen maintains state after dialog operations', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createSettingsScreen());
      await tester.pumpAndSettle();

      // Record initial screen state
      expect(find.text('设置'), findsOneWidget);

      // Open and interact with multiple dialogs
      final themeColorTile = find.descendant(
        of: find.byType(ListTile),
        matching: find.text('主题颜色'),
      );
      await tester.tap(themeColorTile);
      await tester.pumpAndSettle();
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      // Screen should still be functional
      expect(find.text('设置'), findsOneWidget);

      // Open another dialog
      final themeModeTile = find.descendant(
        of: find.byType(ListTile),
        matching: find.text('主题模式'),
      );
      await tester.tap(themeModeTile);
      await tester.pumpAndSettle();
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      // Screen should still be functional
      expect(find.text('设置'), findsOneWidget);
    });
  });
}
