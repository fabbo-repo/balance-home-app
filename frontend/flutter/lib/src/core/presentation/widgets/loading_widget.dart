import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final Color color;
  final String? text;
  final double? width;
  final double? height;
  final double? strokeWidth;

  const LoadingWidget(
      {this.color = Colors.green,
      this.text,
      this.width,
      this.height,
      this.strokeWidth,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: const Color.fromARGB(115, 231, 231, 231),
            width: width ?? 100,
            height: height ?? 100,
            child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeWidth: strokeWidth ?? 6.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              text ?? "",
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
