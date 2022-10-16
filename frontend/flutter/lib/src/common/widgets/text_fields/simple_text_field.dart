import 'package:flutter/material.dart';

class SimpleTextField extends StatelessWidget {
  
  final String title;

  final TextEditingController controller;

  final String? error;

  final Function(String)? onChanged;


  const SimpleTextField({
    required this.title,
    required this.controller,
    this.error,
    this.onChanged,
    Key? key
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 700),
            padding: const EdgeInsets.all(10),
            child: TextField(
              onChanged: onChanged,
              controller: controller,
              decoration: InputDecoration(
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                disabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red)
                ),
                focusedErrorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red)
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