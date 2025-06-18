import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:epico/screens/auth/home_page.dart';

void main() {
  testWidgets('HomePage displays sign up button', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(),
      ),
    );

    expect(find.text('Sign up'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });
}
