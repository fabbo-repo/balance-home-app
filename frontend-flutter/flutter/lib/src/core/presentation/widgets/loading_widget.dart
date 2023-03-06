import 'package:balance_home_app/config/app_layout.dart';
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final Color color;
  final String? text;
  final double? strokeWidth;

  const LoadingWidget(
      {this.color = Colors.green, this.text, this.strokeWidth, Key? key})
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
            Container(
              width: 100,
              height: 100,
              padding: const EdgeInsets.all(AppLayout.genericPadding),
              child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeWidth: strokeWidth ?? 6.0,
              ),
            ),
            if (text != null && text!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppLayout.genericPadding),
                child: Text(
                  text ?? "",
                  style: const TextStyle(fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
