import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/app/theme/app_theme.dart';
import 'package:gallery/core/widgets/adaptive/adaptive_button.dart';
import 'package:gallery/core/widgets/adaptive/adaptive_progress_indicator.dart';
import 'package:gallery/core/widgets/adaptive/adaptive_text_field.dart';

void main() {
  group('Adaptive UI Components (Rule 5.3)', () {
    Widget buildThemedWidget({
      required TargetPlatform platform,
      required Widget child,
    }) {
      final baseTheme = AppThemes.defaultTheme.themeData;
      return MaterialApp(
        theme: baseTheme.copyWith(platform: platform),
        home: Scaffold(body: child),
      );
    }

    testWidgets('AdaptiveButton renders Material ElevatedButton on Android', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildThemedWidget(
          platform: TargetPlatform.android,
          child: AdaptiveButton(text: 'Android Button', onPressed: () {}),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(CupertinoButton), findsNothing);
    });

    testWidgets('AdaptiveButton renders CupertinoButton on iOS', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildThemedWidget(
          platform: TargetPlatform.iOS,
          child: AdaptiveButton(text: 'iOS Button', onPressed: () {}),
        ),
      );

      expect(find.byType(CupertinoButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('AdaptiveTextField renders Material TextFormField on Android', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildThemedWidget(
          platform: TargetPlatform.android,
          child: AdaptiveTextField(
            controller: controller,
            label: 'Android Field',
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byType(CupertinoTextField), findsNothing);
    });

    testWidgets('AdaptiveTextField renders CupertinoTextField on iOS', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildThemedWidget(
          platform: TargetPlatform.iOS,
          child: AdaptiveTextField(controller: controller, label: 'iOS Field'),
        ),
      );

      expect(find.byType(CupertinoTextField), findsOneWidget);
    });

    testWidgets(
      'AdaptiveProgressIndicator renders CircularProgressIndicator on Android',
      (tester) async {
        await tester.pumpWidget(
          buildThemedWidget(
            platform: TargetPlatform.android,
            child: const AdaptiveProgressIndicator(),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byType(CupertinoActivityIndicator), findsNothing);
      },
    );

    testWidgets(
      'AdaptiveProgressIndicator renders CupertinoActivityIndicator on iOS',
      (tester) async {
        await tester.pumpWidget(
          buildThemedWidget(
            platform: TargetPlatform.iOS,
            child: const AdaptiveProgressIndicator(),
          ),
        );

        expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );
  });
}
