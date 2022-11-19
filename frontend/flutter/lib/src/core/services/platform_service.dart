import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:adaptive_breakpoints/adaptive_breakpoints.dart';

/// Service for platform detection
class PlatformService {
  // Whether is web environment
  bool get isWeb => kIsWeb;

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
    getWindowType(context) == AdaptiveWindowType.small;
}