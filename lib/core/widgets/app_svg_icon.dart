import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Centralized SVG icon asset constants loaded strictly from `assets/icons/`.
abstract final class AppIcons {
  static const String arrowRight = 'assets/icons/arrow-right.svg';
  static const String bookOpen = 'assets/icons/book-open.svg';
  static const String cameraOff = 'assets/icons/camera-off.svg';
  static const String chevronRight = 'assets/icons/chevron-right.svg';
  static const String circleAlert = 'assets/icons/circle-alert.svg';
  static const String clock = 'assets/icons/clock.svg';
  static const String coffee = 'assets/icons/coffee.svg';
  static const String compass = 'assets/icons/compass.svg';
  static const String fileText = 'assets/icons/file-text.svg';
  static const String heart = 'assets/icons/heart.svg';
  static const String imageOff = 'assets/icons/image-off.svg';
  static const String image = 'assets/icons/image.svg';
  static const String mapPin = 'assets/icons/map-pin.svg';
  static const String messageCircle = 'assets/icons/message-circle.svg';
  static const String search = 'assets/icons/search.svg';
  static const String slidersHorizontal = 'assets/icons/sliders-horizontal.svg';
  static const String sparkles = 'assets/icons/sparkles.svg';
  static const String user = 'assets/icons/user.svg';
  static const String usersRound = 'assets/icons/users-round.svg';
  static const String users = 'assets/icons/users.svg';
}

/// Reusable SVG icon widget that renders icons from `assets/icons/` with tint and size.
class AppSvgIcon extends StatelessWidget {
  final String assetName;
  final double? size;
  final Color? color;

  const AppSvgIcon(this.assetName, {super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetName,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}
