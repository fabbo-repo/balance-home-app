import 'package:flutter/material.dart';

class SimpleTextField extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String? error;
  final double? maxWidth;
  final int? maxCharacters;
  final bool? enabled;
  final TextAlign? textAlign;
  final Function(String)? onChanged;

  const SimpleTextField(
      {required this.title,
      required this.controller,
      this.error,
      this.maxWidth,
      this.onChanged,
      this.maxCharacters,
      this.enabled,
      this.textAlign,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: maxWidth ?? 700),
            padding: const EdgeInsets.all(10),
            child: TextField(
              enabled: enabled,
              textAlign: textAlign ?? TextAlign.start,
              maxLength: maxCharacters,
              onChanged: onChanged,
              controller: controller,
              decoration: InputDecoration(
                counterText: '',
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
                fillColor: Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : const Color.fromARGB(255, 119, 119, 119),
                labelText: title,
              ),
            ),
          ),
          Text(
            error ?? "",
            style: const TextStyle(color: Colors.red, fontSize: 14),
          )
        ],
      ),
    );
  }
}
