import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:calendar_widget/main.dart';

void main() {
  testWidgets('Calendar app launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CalendarApp(),
      ),
    );

    expect(find.text('Calendar'), findsOneWidget);
    
    expect(find.byIcon(Icons.calendar_month), findsOneWidget);
    
    expect(find.text('Sun'), findsOneWidget);
    expect(find.text('Mon'), findsOneWidget);
    expect(find.text('Tue'), findsOneWidget);
    expect(find.text('Wed'), findsOneWidget);
    expect(find.text('Thu'), findsOneWidget);
    expect(find.text('Fri'), findsOneWidget);
    expect(find.text('Sat'), findsOneWidget);
  });
  
  testWidgets('Theme toggle button is present', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CalendarApp(),
      ),
    );
    
    expect(find.byIcon(Icons.brightness_auto), findsOneWidget);
  });
}
