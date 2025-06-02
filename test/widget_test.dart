// AspirasiKu Flutter App Widget Test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aspirasikuflutter/main.dart';

void main() {
  testWidgets('App should load without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for any animations to complete
    await tester.pumpAndSettle();

    // Verify that the app loads without throwing exceptions
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
