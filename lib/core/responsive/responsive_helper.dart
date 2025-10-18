import 'package:flutter/material.dart';

class ResponsiveHelper {
  static const int mobileBreakpoint = 600;
  static const int tabletBreakpoint = 900;
  static const int desktopBreakpoint = 1200;

  /// Get screen width
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;

  /// Get screen height
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

  /// Check if device is mobile
  static bool isMobile(BuildContext context) => screenWidth(context) < mobileBreakpoint;

  /// Check if device is tablet
  static bool isTablet(BuildContext context) =>
      screenWidth(context) >= mobileBreakpoint && screenWidth(context) < desktopBreakpoint;

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) => screenWidth(context) >= desktopBreakpoint;

  /// Get responsive text scale factor
  static double getTextScale(BuildContext context) {
    double width = screenWidth(context);
    if (width < mobileBreakpoint) return 0.8;
    if (width < tabletBreakpoint) return 0.9;
    if (width < desktopBreakpoint) return 1.0;
    return 1.1;
  }

  /// Get responsive padding
  static EdgeInsets getPadding(BuildContext context) {
    double width = screenWidth(context);
    if (width < mobileBreakpoint) return const EdgeInsets.all(16);
    if (width < tabletBreakpoint) return const EdgeInsets.all(20);
    return const EdgeInsets.all(24);
  }

  /// Get responsive horizontal padding
  static EdgeInsets getHorizontalPadding(BuildContext context) {
    double width = screenWidth(context);
    double horizontal = width < mobileBreakpoint ? 16 : (width < tabletBreakpoint ? 20 : 24);
    return EdgeInsets.symmetric(horizontal: horizontal);
  }

  /// Get responsive vertical padding
  static EdgeInsets getVerticalPadding(BuildContext context) {
    double width = screenWidth(context);
    double vertical = width < mobileBreakpoint ? 12 : (width < tabletBreakpoint ? 16 : 20);
    return EdgeInsets.symmetric(vertical: vertical);
  }

  /// Get responsive card height
  static double getCardHeight(BuildContext context) {
    double width = screenWidth(context);
    if (width < mobileBreakpoint) return 120;
    if (width < tabletBreakpoint) return 140;
    return 160;
  }

  /// Get responsive image height
  static double getImageHeight(BuildContext context) {
    double width = screenWidth(context);
    if (width < mobileBreakpoint) return 200;
    if (width < tabletBreakpoint) return 250;
    return 300;
  }

  /// Get responsive font size
  static double getFontSize(BuildContext context, double baseSize) {
    return baseSize * getTextScale(context);
  }

  /// Get responsive icon size
  static double getIconSize(BuildContext context, double baseSize) {
    double width = screenWidth(context);
    if (width < mobileBreakpoint) return baseSize * 0.8;
    if (width < tabletBreakpoint) return baseSize * 0.9;
    return baseSize;
  }

  /// Get responsive button height
  static double getButtonHeight(BuildContext context) {
    double width = screenWidth(context);
    if (width < mobileBreakpoint) return 44;
    if (width < tabletBreakpoint) return 48;
    return 52;
  }

  /// Get responsive border radius
  static BorderRadius getBorderRadius(BuildContext context) {
    double width = screenWidth(context);
    if (width < mobileBreakpoint) return BorderRadius.circular(8);
    if (width < tabletBreakpoint) return BorderRadius.circular(12);
    return BorderRadius.circular(16);
  }

  /// Get responsive spacing
  static double getSpacing(BuildContext context, double baseSpacing) {
    double width = screenWidth(context);
    if (width < mobileBreakpoint) return baseSpacing * 0.8;
    if (width < tabletBreakpoint) return baseSpacing * 0.9;
    return baseSpacing;
  }

  /// Get responsive grid count
  static int getGridCount(BuildContext context) {
    double width = screenWidth(context);
    if (width < mobileBreakpoint) return 2;
    if (width < tabletBreakpoint) return 3;
    if (width < desktopBreakpoint) return 4;
    return 5;
  }

  /// Get responsive aspect ratio for movie cards
  static double getMovieCardAspectRatio(BuildContext context) {
    double width = screenWidth(context);
    if (width < mobileBreakpoint) return 0.7;
    if (width < tabletBreakpoint) return 0.75;
    return 0.8;
  }

  /// Get responsive carousel height
  static double getCarouselHeight(BuildContext context) {
    double width = screenWidth(context);
    if (width < mobileBreakpoint) return 300;
    if (width < tabletBreakpoint) return 400;
    return 500;
  }

  /// Get responsive app bar height
  static double getAppBarHeight(BuildContext context) {
    double width = screenWidth(context);
    if (width < mobileBreakpoint) return kToolbarHeight;
    return kToolbarHeight + 20;
  }

  /// Get responsive bottom navigation height
  static double getBottomNavHeight(BuildContext context) {
    double width = screenWidth(context);
    if (width < mobileBreakpoint) return 60;
    return 70;
  }
}
