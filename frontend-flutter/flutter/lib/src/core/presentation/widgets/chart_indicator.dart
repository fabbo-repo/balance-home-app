import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChartIndicator extends StatelessWidget {
  const ChartIndicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor = const Color(0xff505050),
  });
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: GoogleFonts.openSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        )
      ],
    );
  }
}
