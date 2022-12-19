import 'package:flutter/material.dart';

class SimpleTextButton extends StatelessWidget {
  final bool enabled;
  final void Function() onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;

  const SimpleTextButton({
    required this.child,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
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
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: (!enabled) ? null : onPressed,
        style: style, 
        child: child
      ),
    );
  }
}
