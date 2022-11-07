import 'package:flutter/material.dart';

class SimpleTextButton extends StatelessWidget {
  final bool enabled;
  
  final void Function() onPressed;

  final Widget child;

  final Color? backgroundColor;

  final Color? foregroundColor;

  const SimpleTextButton({
    required this.child,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    bool? enabled,
    super.key
  }) : enabled = enabled ?? true;

  @override
  Widget build(BuildContext context) {
    ButtonStyle? style = ButtonStyle(
      backgroundColor: (backgroundColor == null) ? 
        null : 
        MaterialStateProperty.all<Color>(backgroundColor!),
      foregroundColor:  (foregroundColor == null) ? 
        null : 
        MaterialStateProperty.all<Color>(foregroundColor!)
    );
    return ElevatedButton(
      onPressed: (!enabled) ? null : onPressed,
      style: style, 
      child: child
    );
  }
}
