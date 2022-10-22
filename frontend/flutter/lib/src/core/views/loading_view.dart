import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  final void Function(BuildContext context)? func;
  const LoadingView({
    this.func,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    if (func != null) func!(context);
    return Scaffold(
      body: Center(
        child: Container(
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