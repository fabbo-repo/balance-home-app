import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final String message;

  const ErrorView({
    required this.message,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(message),
      ),
    );
  }
}