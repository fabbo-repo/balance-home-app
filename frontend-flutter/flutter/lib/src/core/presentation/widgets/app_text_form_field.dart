import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextFormField extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final Color? textColor;
  final Color? readOnlyColor;
  final Color? fillColor;
  final Color? focusedColor;
  final Color? enabledBorderColor;
  final Color? borderColor;
  final bool? filled;
  final double? maxWidth;
  final double? maxHeight;
  final double? fontSize;
  final int? maxCharacters;
  final bool readOnly;
  final int? minLines;
  final int? maxLines;
  final bool multiLine;
  final bool showCounterText;
  final TextAlign? textAlign;
  final Function(String)? onChanged;
  final Function()? onTap;
  final String? Function(String?)? validator;

  const AppTextFormField(
      {required this.title,
      required this.controller,
      this.textColor,
      this.readOnlyColor,
      this.fillColor,
      this.focusedColor,
      this.enabledBorderColor,
      this.borderColor,
      this.filled,
      this.maxWidth,
      this.maxHeight,
      this.onChanged,
      this.onTap,
      this.validator,
      this.fontSize = 14,
      this.maxCharacters,
      this.readOnly = false,
      this.minLines,
      this.maxLines = 1,
      this.multiLine = false,
      this.showCounterText = false,
      this.textAlign,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            constraints: BoxConstraints(
                maxHeight: maxHeight ?? double.infinity,
                maxWidth: maxWidth ?? 700),
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              keyboardType: multiLine ? TextInputType.multiline : null,
              minLines: minLines,
              maxLines: maxLines,
              readOnly: readOnly,
              textAlign: textAlign ?? TextAlign.start,
              maxLength: maxCharacters,
              onChanged: readOnly ? null : onChanged,
              onTap: readOnly ? null : onTap,
              controller: controller,
              validator: validator,
              style: GoogleFonts.openSans(color: textColor),
              decoration: InputDecoration(
                counterText: showCounterText ? null : '',
                labelText: title,
                errorStyle: GoogleFonts.openSans(fontSize: fontSize),
                enabledBorder: enabledBorderColor != null
                    ? OutlineInputBorder(
                        borderSide: BorderSide(color: enabledBorderColor!),
                      )
                    : null,
                focusedBorder: focusedColor != null
                    ? OutlineInputBorder(
                        borderSide: BorderSide(color: focusedColor!),
                      )
                    : null,
                border: borderColor != null
                    ? OutlineInputBorder(
                        borderSide: BorderSide(color: borderColor!))
                    : null,
                labelStyle: GoogleFonts.openSans(color: textColor),
                hintStyle: GoogleFonts.openSans(color: textColor),
                filled: filled,
                fillColor: readOnly
                    ? readOnlyColor ?? const Color.fromARGB(108, 167, 167, 167)
                    : fillColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
