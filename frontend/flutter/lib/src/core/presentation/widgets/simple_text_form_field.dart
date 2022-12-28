import 'package:flutter/material.dart';

class SimpleTextFormField extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String? error;
  final double? maxWidth;
  final double? maxHeight;
  final int? maxCharacters;
  final bool? readOnly;
  final int? minLines;
  final int? maxLines;
  final bool multiLine;
  final bool showCounterText;
  final TextAlign? textAlign;
  final Function(String)? onChanged;
  final Function()? onTap;
  final String? Function(String?)? validator;

  const SimpleTextFormField(
      {required this.title,
      required this.controller,
      this.error,
      this.maxWidth,
      this.maxHeight,
      this.onChanged,
      this.onTap,
      this.validator,
      this.maxCharacters,
      this.readOnly,
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
              readOnly: readOnly ?? false,
              textAlign: textAlign ?? TextAlign.start,
              maxLength: maxCharacters,
              onChanged: onChanged,
              onTap: onTap,
              controller: controller,
              validator: validator,
              decoration: InputDecoration(
                counterText: showCounterText ? null : '',
                labelText: title,
                errorText: error,
                errorStyle: const TextStyle(fontSize: 14),
                enabledBorder: OutlineInputBorder(
                  borderSide: (error != null && error != "")
                      ? const BorderSide(color: Colors.red)
                      : const BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: (error != null && error != "")
                      ? const BorderSide(color: Colors.red)
                      : const BorderSide(color: Colors.blue),
                ),
                border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
                labelStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white),
                filled: true,
                fillColor: readOnly != null && readOnly!
                    ? const Color.fromARGB(108, 167, 167, 167)
                    : Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : const Color.fromARGB(255, 119, 119, 119),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
