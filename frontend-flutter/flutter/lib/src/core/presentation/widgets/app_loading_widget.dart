import 'package:balance_home_app/config/app_layout.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppLoadingWidget extends StatelessWidget {
  final Color color;
  final String? text;
  final double? strokeWidth;

  const AppLoadingWidget(
      {this.color = Colors.green, this.text, this.strokeWidth, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 170,
        height: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppLayout.containerRadius),
          color: const Color.fromARGB(115, 231, 231, 231),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              padding: const EdgeInsets.all(AppLayout.genericPadding),
              child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeWidth: strokeWidth ?? 7.0,
              ),
            ),
            if (text != null && text!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppLayout.genericPadding),
                child: Text(
                  text ?? "",
                  style: GoogleFonts.openSans(fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
