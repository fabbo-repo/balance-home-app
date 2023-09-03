import 'package:balance_home_app/config/app_layout.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppErrorWidget extends StatelessWidget {
  final Color? color;
  final String? text;
  final double? strokeWidth;
  final IconData? icon;

  const AppErrorWidget(
      {this.color, this.text, this.strokeWidth, this.icon, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppLayout.containerRadius),
          color: const Color.fromARGB(115, 231, 231, 231),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              color: color ?? Colors.red,
              size: 110,
            ),
            if (text != null && text!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppLayout.genericPadding),
                child: Text(
                  text ?? "",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
