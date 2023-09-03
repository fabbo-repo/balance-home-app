import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:adaptive_breakpoints/adaptive_breakpoints.dart';

/// Utils for platform detection
class PlatformUtils {
  // Whether is web environment
  static bool get isWeb => kIsWeb;

  static bool get isAndroid =>
      defaultTargetPlatform == TargetPlatform.android && !isWeb;

  static bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS && !isWeb;

  static bool get isWindows =>
      defaultTargetPlatform == TargetPlatform.windows && !isWeb;

  static bool get isLinux => defaultTargetPlatform == TargetPlatform.linux && !isWeb;

  static bool get isMacOS => defaultTargetPlatform == TargetPlatform.macOS && !isWeb;

  // Whether is mobile environment
  static bool get isMobile =>
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) &&
      !isWeb;

  // Whether is desktop or web environment
  static bool get isDesktopOrWeb =>
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux ||
      isWeb;

  /// Gets the platform where the application is executed.
  ///
  /// Web is not included.
  static TargetPlatform get targetPlatform => defaultTargetPlatform;

  // Whether the platform window is considered as large
  static bool isLargeWindow(BuildContext context) =>
      getWindowType(context) >= AdaptiveWindowType.large;

  // Whether the platform window is considered as medium
  static bool isMediumWindow(BuildContext context) =>
      getWindowType(context) == AdaptiveWindowType.medium;

  // Whether the platform window is considered as small
  static bool isSmallWindow(BuildContext context) =>
      getWindowType(context) == AdaptiveWindowType.small ||
      getWindowType(context) == AdaptiveWindowType.xsmall;
}
