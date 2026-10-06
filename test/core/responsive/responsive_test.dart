import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/core/responsive/responsive.dart';

void main() {
  group('Responsive Core Calculations', () {
    test(
      'deviceTypeForWidth classifies widths correctly into size classes',
      () {
        // Compact (< 600)
        expect(Responsive.deviceTypeForWidth(320), DeviceScreenType.compact);
        expect(Responsive.deviceTypeForWidth(375), DeviceScreenType.compact);
        expect(Responsive.deviceTypeForWidth(599.9), DeviceScreenType.compact);

        // Medium (600 - 839.9)
        expect(Responsive.deviceTypeForWidth(600), DeviceScreenType.medium);
        expect(Responsive.deviceTypeForWidth(768), DeviceScreenType.medium);
        expect(Responsive.deviceTypeForWidth(839.9), DeviceScreenType.medium);

        // Expanded (>= 840)
        expect(Responsive.deviceTypeForWidth(840), DeviceScreenType.expanded);
        expect(Responsive.deviceTypeForWidth(1024), DeviceScreenType.expanded);
        expect(Responsive.deviceTypeForWidth(1440), DeviceScreenType.expanded);
      },
    );

    test(
      'galleryColumnsForWidth calculates appropriate columns across devices',
      () {
        // Very small phones (< 360)
        expect(Responsive.galleryColumnsForWidth(320), 2);

        // Standard portrait phones (360 - 599)
        expect(Responsive.galleryColumnsForWidth(375), 3);
        expect(Responsive.galleryColumnsForWidth(414), 3);

        // Large phones in landscape / small tablets (600 - 899)
        expect(Responsive.galleryColumnsForWidth(600), 4);
        expect(Responsive.galleryColumnsForWidth(768), 4);

        // Standard tablets (900 - 1199)
        expect(Responsive.galleryColumnsForWidth(900), 5);
        expect(Responsive.galleryColumnsForWidth(1024), 5);

        // Large tablets / desktop screens (>= 1200)
        expect(Responsive.galleryColumnsForWidth(1200), 6);
        expect(Responsive.galleryColumnsForWidth(1600), 6);
      },
    );

    test('horizontalGutterForWidth provides proper responsive margins', () {
      // Compact phones: 16dp
      expect(Responsive.horizontalGutterForWidth(375), 16.0);

      // Medium screens: 24dp
      expect(Responsive.horizontalGutterForWidth(768), 24.0);

      // Expanded screens: 32dp
      expect(Responsive.horizontalGutterForWidth(1024), 32.0);
    });
  });

  group('Responsive Context Helpers', () {
    testWidgets('calculates correctly from BuildContext MediaQuery', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      late DeviceScreenType detectedDeviceType;
      late int detectedColumns;
      late double detectedGutter;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                detectedDeviceType = Responsive.deviceType(context);
                detectedColumns = Responsive.galleryColumns(context);
                detectedGutter = Responsive.horizontalGutter(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(detectedDeviceType, DeviceScreenType.compact);
      expect(detectedColumns, 3);
      expect(detectedGutter, 16.0);
    });
  });
}
