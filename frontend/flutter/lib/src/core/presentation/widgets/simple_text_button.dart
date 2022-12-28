import 'package:flutter/material.dart';

class SimpleTextButton extends StatelessWidget {
  final void Function() onPressed;
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;
  final bool enabled;
  final bool loading;

  const SimpleTextButton(
      {required this.text,
      required this.onPressed,
      this.backgroundColor,
      this.textColor,
      this.foregroundColor,
      this.width,
      this.height,
      this.enabled = true,
      this.loading = false,
      super.key});

  @override
  Widget build(BuildContext context) {
    Color backColor = backgroundColor ?? Theme.of(context).colorScheme.primary;
    ButtonStyle? style = ButtonStyle(
      backgroundColor:
          MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.pressed) ||
            states.contains(MaterialState.disabled)) {
          return backColor.withOpacity(0.6);
        }
        return backColor;
      }),
      foregroundColor: (foregroundColor == null)
          ? null
          : MaterialStateProperty.all<Color>(foregroundColor!),
    );
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: (!enabled) ? null : onPressed,
        style: style,
        child: loading
            ? const CircularProgressIndicator()
            : Text(
                text,
                style:
                    TextStyle(fontSize: 16, color: textColor ?? Colors.white),
              ),
      ),
    );
  }
}
