import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppPasswordTextFormField extends StatefulWidget {
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

  const AppPasswordTextFormField(
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
  State<AppPasswordTextFormField> createState() =>
      _AppPasswordTextFormFieldState();
}

class _AppPasswordTextFormFieldState extends State<AppPasswordTextFormField> {
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            constraints: BoxConstraints(
                maxHeight: widget.maxHeight ?? double.infinity,
                maxWidth: widget.maxWidth ?? 700),
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              obscureText: !showPassword,
              keyboardType: widget.multiLine ? TextInputType.multiline : null,
              minLines: widget.minLines,
              maxLines: widget.maxLines,
              readOnly: widget.readOnly,
              textAlign: widget.textAlign ?? TextAlign.start,
              maxLength: widget.maxCharacters,
              onChanged: widget.onChanged,
              onTap: widget.onTap,
              controller: widget.controller,
              validator: widget.validator,
              style: GoogleFonts.openSans(color: widget.textColor),
              decoration: InputDecoration(
                counterText: widget.showCounterText ? null : '',
                labelText: widget.title,
                errorStyle: GoogleFonts.openSans(fontSize: widget.fontSize),
                enabledBorder: widget.enabledBorderColor != null
                    ? OutlineInputBorder(
                        borderSide:
                            BorderSide(color: widget.enabledBorderColor!),
                      )
                    : null,
                focusedBorder: widget.focusedColor != null
                    ? OutlineInputBorder(
                        borderSide: BorderSide(color: widget.focusedColor!),
                      )
                    : null,
                border: widget.borderColor != null
                    ? OutlineInputBorder(
                        borderSide: BorderSide(color: widget.borderColor!))
                    : null,
                labelStyle: GoogleFonts.openSans(color: widget.textColor),
                hintStyle: GoogleFonts.openSans(color: widget.textColor),
                filled: widget.filled,
                fillColor: widget.readOnly
                    ? widget.readOnlyColor ??
                        const Color.fromARGB(108, 167, 167, 167)
                    : widget.fillColor,
                suffixIcon: InkWell(
                  onTap: () {
                    setState(() {
                      showPassword = !showPassword;
                    });
                  },
                  child: (showPassword)
                      ? Icon(Icons.visibility, color: widget.textColor)
                      : Icon(Icons.visibility_off, color: widget.textColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
