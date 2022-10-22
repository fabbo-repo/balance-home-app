import 'dart:developer';

import 'package:flutter/material.dart';

class SimpleTextButton extends StatelessWidget {
  final bool _enabled;
  
  final void Function() onPressed;

  final Widget child;

  final Color? textColor;

  final Color? backgroundColor;

  final Color? foregroundColor;

  const SimpleTextButton({
    required this.child,
    required this.onPressed,
    this.textColor,
    this.backgroundColor,
    this.foregroundColor,
    bool? enabled,
    super.key
  }) : _enabled = enabled ?? true;

  @override
  Widget build(BuildContext context) {
    ButtonStyle? style = ButtonStyle(
      textStyle: MaterialStateProperty.all<TextStyle>(
        TextStyle(color: textColor)
      ),
      backgroundColor: (backgroundColor == null) ? 
        null : 
        MaterialStateProperty.all<Color>(backgroundColor!),
      foregroundColor:  (foregroundColor == null) ? 
        null : 
        MaterialStateProperty.all<Color>(foregroundColor!)
    );
    return ElevatedButton(
      onPressed: (!_enabled) ? null : onPressed, 
      child: child,
      style: style
    );
  }
}
