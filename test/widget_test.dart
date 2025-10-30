// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:travelflow/main.dart';

void main() {
  testWidgets('TravelFlow app launches', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TravelFlowApp());

    // Verify that the app title is displayed.
    expect(find.text('TravelFlow'), findsOneWidget);

    // Verify that the form fields are present.
    expect(find.text('开始您的旅程'), findsOneWidget);
    expect(find.text('出发城市'), findsOneWidget);
    expect(find.text('目的地城市'), findsOneWidget);

    // Verify that the generate button is present.
    expect(find.text('生成旅行计划'), findsOneWidget);
  });
}
