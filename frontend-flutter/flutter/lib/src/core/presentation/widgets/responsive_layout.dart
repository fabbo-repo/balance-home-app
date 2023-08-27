import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileChild;
  final Widget tabletChild;
  final Widget desktopChild;

  /// Layout used to display three diferent [Widgets] depending
  /// on the shortest distance from the device. Distances will be
  /// related to mobile, tablet and desktop platforms.
  const ResponsiveLayout(
      {super.key,
      required this.mobileChild,
      required this.tabletChild,
      required this.desktopChild});

  /// Gets the side of the screen with the shortest distance
  /// from the device, and compares it with a magic number
  /// used to classify wide screens for mobile, tablet and desktop
  /// platforms.
  ///
  /// For convenience, 600 is usually used for 7 inches tablets,
  /// but there are exceptions such as the *Nexus 7 2012* whose
  /// value is 552, therefore it is preferred to use 550 for tablets.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double width = MediaQueryData.fromView(
                WidgetsBinding.instance.platformDispatcher.views.first)
            .size
            .width;
        if (width < 550) {
          return mobileChild;
        } else if (width < 1024) {
          return tabletChild;
        } else {
          return desktopChild;
        }
      },
    );
  }
}
