import 'package:flutter/material.dart';

class SimpleTextField extends StatelessWidget {
  
  final String title;
  final TextEditingController controller;
  final String? error;
  final double? maxWidth;
  final int? maxCharacters;
  final TextAlign? textAlign;
  final Function(String)? onChanged;


  const SimpleTextField({
    required this.title,
    required this.controller,
    this.error,
    this.maxWidth,
    this.onChanged,
    this.maxCharacters,
    this.textAlign,
    Key? key
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: maxWidth ?? 700),
            padding: const EdgeInsets.all(10),
            child: TextField(
              textAlign: textAlign ?? TextAlign.start,
              maxLength: maxCharacters,
              onChanged: onChanged,
              controller: controller,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: 
                    (error != null && error != "") ?
                      const BorderSide(color: Colors.red):
                      const BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: 
                    (error != null && error != "") ?
                      const BorderSide(color: Colors.red):
                      const BorderSide(color: Colors.blue),
                ),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black)
                ),
                labelStyle: const TextStyle(color: Colors.black),
                filled: true,
                fillColor: Colors.white,
                labelText: title,
              ),
            ),
          ),
          Text(
            error ?? "",
            style: const TextStyle(
              color: Colors.red, 
              fontSize: 14
            ),
          )
        ],
      ),
    );
  }
}