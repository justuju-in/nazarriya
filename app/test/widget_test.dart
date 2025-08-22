// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nazarriya_app/main.dart';

void main() {
  testWidgets('NazarRiya app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NazarRiyaApp());

    // Verify that the app title is displayed
    expect(find.text('NazarRiya'), findsOneWidget);
    expect(find.text('Talk. Question. Change.'), findsOneWidget);
    
    // Verify that the main action buttons are present
    expect(find.text('Chat with Riya and Nazar'), findsOneWidget);
    expect(find.text('Browse our Library'), findsOneWidget);
    expect(find.text('Call our Helpline'), findsOneWidget);
  });
}
