import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/app/app.dart';

void main() {
  testWidgets('GalleryApp boots into AppShell and displays responsive info', (
    tester,
  ) async {
    await tester.pumpWidget(const GalleryApp());
    await tester.pump();

    // Verify header and foundation labels
    expect(find.text('AI Gallery Foundation'), findsOneWidget);
    expect(find.text('Theme Selector'), findsOneWidget);
    expect(find.text('Responsive Grid System'), findsOneWidget);

    // Verify all registered theme names appear
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Midnight Blue'), findsOneWidget);

    // Tap the 'Light' theme button
    await tester.tap(find.text('Light'));
    await tester.pump();

    // Verify MaterialApp updated theme brightness without errors
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.theme?.brightness, equals(Brightness.light));

    // Tap the 'Midnight Blue' theme button
    await tester.tap(find.text('Midnight Blue'));
    await tester.pump();

    final materialAppUpdated = tester.widget<MaterialApp>(
      find.byType(MaterialApp),
    );
    expect(materialAppUpdated.theme?.brightness, equals(Brightness.dark));
  });
}
