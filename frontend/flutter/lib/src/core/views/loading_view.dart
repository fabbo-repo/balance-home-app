import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
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