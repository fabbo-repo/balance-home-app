import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  /// Named route for [LoadingView]
  static const String routeName = 'loading';

  /// Path route for [LoadingView]
  static const String routePath = 'load';

  final void Function(BuildContext context)? func;
  const LoadingView({
    this.func,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    if (func != null) func!(context);
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator.adaptive(
            valueColor:  AlwaysStoppedAnimation<Color>(Colors.green),
            strokeWidth: 6.0,
          ),
        ),
      ),
    );
  }
}