import 'package:flutter/widgets.dart';

/// Device size classifications based on screen width.
enum DeviceScreenType {
  compact, // < 600dp (standard phones)
  medium, // 600dp - 839dp (foldables / small tablets / landscape phones)
  expanded, // >= 840dp (tablets, desktop displays)
}

/// Centralized responsive design calculations and layout metrics.
///
/// Direct `MediaQuery` layout calculations should NOT be scattered across
/// UI widgets; use this centralized utility instead per project rules.
class Responsive {
  Responsive._();

  // Standard breakpoints
  static const double compactBreakpoint = 600.0;
  static const double mediumBreakpoint = 840.0;

  // Screen metrics
  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static Orientation orientation(BuildContext context) =>
      MediaQuery.orientationOf(context);

  // Device classification
  static DeviceScreenType deviceType(BuildContext context) =>
      deviceTypeForWidth(screenWidth(context));

  static DeviceScreenType deviceTypeForWidth(double width) {
    if (width < compactBreakpoint) {
      return DeviceScreenType.compact;
    }
    if (width < mediumBreakpoint) {
      return DeviceScreenType.medium;
    }
    return DeviceScreenType.expanded;
  }

  static bool isCompact(BuildContext context) =>
      deviceType(context) == DeviceScreenType.compact;

  static bool isMedium(BuildContext context) =>
      deviceType(context) == DeviceScreenType.medium;

  static bool isExpanded(BuildContext context) =>
      deviceType(context) == DeviceScreenType.expanded;

  // Responsive gallery column calculation
  static int galleryColumns(BuildContext context) =>
      galleryColumnsForWidth(screenWidth(context));

  static int galleryColumnsForWidth(double width) {
    if (width < 360.0) {
      return 2; // Very small phones
    }
    if (width < 600.0) {
      return 3; // Standard portrait phones
    }
    if (width < 900.0) {
      return 4; // Large phones in landscape / small tablets
    }
    if (width < 1200.0) {
      return 5; // Standard tablets
    }
    return 6; // Large tablets / desktop screens
  }

  // Responsive gutters and padding
  static double horizontalGutter(BuildContext context) =>
      horizontalGutterForWidth(screenWidth(context));

  static double horizontalGutterForWidth(double width) {
    if (width < compactBreakpoint) {
      return 16.0;
    }
    if (width < mediumBreakpoint) {
      return 24.0;
    }
    return 32.0;
  }

  static EdgeInsets pagePadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: horizontalGutter(context),
      vertical: 16.0,
    );
  }
}
