import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Centralized SVG icon asset constants loaded strictly from `assets/icons/`.
abstract final class AppIcons {
  static const String arrowRight = 'assets/icons/arrow-right.svg';
  static const String bookOpen = 'assets/icons/book-open.svg';
  static const String cameraOff = 'assets/icons/camera-off.svg';
  static const String chevronLeft = 'assets/icons/chevron-left.svg';
  static const String chevronRight = 'assets/icons/chevron-right.svg';
  static const String circleAlert = 'assets/icons/circle-alert.svg';
  static const String clock = 'assets/icons/clock.svg';
  static const String codeXml = 'assets/icons/code-xml.svg';
  static const String coffee = 'assets/icons/coffee.svg';
  static const String compass = 'assets/icons/compass.svg';
  static const String crown = 'assets/icons/crown.svg';
  static const String database = 'assets/icons/database.svg';
  static const String fileText = 'assets/icons/file-text.svg';
  static const String gallery = 'assets/icons/gallery-vertical-end.svg';
  static const String heart = 'assets/icons/heart.svg';
  static const String imageOff = 'assets/icons/image-off.svg';
  static const String image = 'assets/icons/image.svg';
  static const String images = 'assets/icons/images.svg';
  static const String info = 'assets/icons/info.svg';
  static const String logOut = 'assets/icons/log-out.svg';
  static const String mapPin = 'assets/icons/map-pin.svg';
  static const String messageCircle = 'assets/icons/message-circle.svg';
  static const String moon = 'assets/icons/moon.svg';
  static const String moonStar = 'assets/icons/moon-star.svg';
  static const String packageIcon = 'assets/icons/package.svg';
  static const String search = 'assets/icons/search.svg';
  static const String shield = 'assets/icons/shield.svg';
  static const String slidersHorizontal = 'assets/icons/sliders-horizontal.svg';
  static const String smartphone = 'assets/icons/smartphone.svg';
  static const String sparkles = 'assets/icons/sparkles.svg';
  static const String sun = 'assets/icons/sun.svg';
  static const String user = 'assets/icons/user.svg';
  static const String userRound = 'assets/icons/user-round.svg';
  static const String usersRound = 'assets/icons/users-round.svg';
  static const String users = 'assets/icons/users.svg';
}

/// Reusable SVG icon widget that renders icons from `assets/icons/` with tint, size, and rotation.
class AppSvgIcon extends StatelessWidget {
  final String assetName;
  final double? size;
  final Color? color;
  final int quarterTurns;

  const AppSvgIcon(
    this.assetName, {
    super.key,
    this.size = 24,
    this.color,
    this.quarterTurns = 0,
  });

  @override
  Widget build(BuildContext context) {
    Widget icon = SvgPicture.asset(
      assetName,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
    if (quarterTurns != 0) {
      icon = RotatedBox(quarterTurns: quarterTurns, child: icon);
    }
    return icon;
  }
}
