import 'package:flutter/material.dart';

class PasswordTextFormField extends StatefulWidget {
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

  const PasswordTextFormField(
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
  State<PasswordTextFormField> createState() => _PasswordTextFormFieldState();
}

class _PasswordTextFormFieldState extends State<PasswordTextFormField> {
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
              readOnly: widget.readOnly ?? false,
              textAlign: widget.textAlign ?? TextAlign.start,
              maxLength: widget.maxCharacters,
              onChanged: widget.onChanged,
              onTap: widget.onTap,
              controller: widget.controller,
              validator: widget.validator,
              decoration: InputDecoration(
                counterText: widget.showCounterText ? null : '',
                labelText: widget.title,
                errorText: widget.error,
                errorStyle: const TextStyle(fontSize: 14),
                enabledBorder: OutlineInputBorder(
                  borderSide: (widget.error != null && widget.error != "")
                      ? const BorderSide(color: Colors.red)
                      : const BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: (widget.error != null && widget.error != "")
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
                fillColor: widget.readOnly != null && widget.readOnly!
                    ? const Color.fromARGB(108, 167, 167, 167)
                    : Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : const Color.fromARGB(255, 119, 119, 119),
                suffixIcon: InkWell(
                  onTap: () {
                    setState(() {
                      showPassword = !showPassword;
                    });
                  },
                  child: (showPassword)
                      ? const Icon(Icons.visibility)
                      : const Icon(Icons.visibility_off),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
