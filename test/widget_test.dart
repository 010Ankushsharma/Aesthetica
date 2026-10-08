import 'package:aesthetica/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Dark theme smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(
          body: Center(child: Text('Aesthetica')),
        ),
      ),
    );

    expect(find.text('Aesthetica'), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
