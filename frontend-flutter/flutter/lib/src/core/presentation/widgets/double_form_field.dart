import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class DoubleFormField extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final double? maxWidth;
  final double? maxHeight;
  final bool? readOnly;
  final TextAlign? align;
  final Function(double?)? onChanged;
  final Function()? onTap;
  final String? Function(String?)? validator;

  const DoubleFormField(
      {required this.title,
      required this.controller,
      this.maxWidth,
      this.maxHeight,
      this.onChanged,
      this.onTap,
      this.validator,
      this.readOnly,
      this.align,
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
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[
                TextInputFormatter.withFunction(
                  (oldValue, newValue) {
                    if (newValue.text.isEmpty) {
                      return const TextEditingValue(text: "0");
                    }
                    return newValue;
                  },
                ),
                TextInputFormatter.withFunction(
                  (oldValue, newValue) {
                    if (RegExp(r'^[0-9]+[,.]{0,1}[0-9]{0,2}$')
                        .hasMatch(newValue.text)) return newValue;
                    return oldValue;
                  },
                ),
                TextInputFormatter.withFunction(
                  (oldValue, newValue) => newValue.copyWith(
                    text: newValue.text.replaceAll('.', ','),
                  ),
                ),
              ],
              readOnly: readOnly ?? false,
              textAlign: align ?? TextAlign.start,
              maxLength: 300,
              onChanged: onChanged == null
                  ? null
                  : (value) {
                      value = value.replaceAll(',', '.');
                      onChanged!(double.tryParse(value));
                    },
              onTap: onTap,
              controller: controller,
              validator: validator,
              decoration: InputDecoration(
                counterText: '',
                labelText: title,
                errorStyle: GoogleFonts.openSans(fontSize: 14),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black)),
                labelStyle: GoogleFonts.openSans(
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
