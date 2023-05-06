import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:adaptive_breakpoints/adaptive_breakpoints.dart';

/// Utils for platform detection
class PlatformUtils {
  // Whether is web environment
  bool get isWeb => kIsWeb;

  bool get isAndroid =>
      defaultTargetPlatform == TargetPlatform.android && !isWeb;

  bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS && !isWeb;

  bool get isWindows =>
      defaultTargetPlatform == TargetPlatform.windows && !isWeb;

  bool get isLinux => defaultTargetPlatform == TargetPlatform.linux && !isWeb;

  bool get isMacOS => defaultTargetPlatform == TargetPlatform.macOS && !isWeb;

  // Whether is mobile environment
  bool get isMobile =>
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) &&
      !isWeb;

  // Whether is desktop or web environment
  bool get isDesktopOrWeb =>
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux ||
      isWeb;

  /// Gets the platform where the application is executed.
  ///
  /// Web is not included.
  TargetPlatform get targetPlatform => defaultTargetPlatform;

  // Whether the platform window is considered as large
  bool isLargeWindow(BuildContext context) =>
      getWindowType(context) >= AdaptiveWindowType.large;

  // Whether the platform window is considered as medium
  bool isMediumWindow(BuildContext context) =>
      getWindowType(context) == AdaptiveWindowType.medium;

  // Whether the platform window is considered as small
  bool isSmallWindow(BuildContext context) =>
      getWindowType(context) == AdaptiveWindowType.small ||
      getWindowType(context) == AdaptiveWindowType.xsmall;
}
