import 'package:balance_home_app/config/app_layout.dart';
import 'package:flutter/material.dart';

class CustomErrorWidget extends StatelessWidget {
  final Color color;
  final String? text;
  final double? strokeWidth;

  const CustomErrorWidget(
      {this.color = const Color.fromARGB(255, 211, 33, 33),
      this.text,
      this.strokeWidth,
      Key? key})
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
              Icons.error_outline,
              color: color,
              size: 110,
            ),
            if (text != null && text!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppLayout.genericPadding),
                child: Text(
                  text ?? "",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
