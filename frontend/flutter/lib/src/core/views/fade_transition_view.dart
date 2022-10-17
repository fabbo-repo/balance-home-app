import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A view that fades in an out.
class FadeTransitionView extends CustomTransitionPage<void> {

  /// Creates a [FadeTransitionView].
  FadeTransitionView({
    required LocalKey key,
    required Widget child,
  }) : super(
    key: key,
    transitionsBuilder: (BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) =>
    FadeTransition(
      opacity: animation.drive(_curveTween),
      child: child,
    ),
    child: child
  );

  static final CurveTween _curveTween = CurveTween(curve: Curves.easeIn);
}