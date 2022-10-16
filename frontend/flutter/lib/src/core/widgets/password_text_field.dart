import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {
  final String title;

  final TextEditingController controller;

  const PasswordTextField(
      {required this.title, required this.controller, Key? key})
      : super(key: key);

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        padding: const EdgeInsets.all(10),
        child: TextField(
          obscureText: !showPassword,
          controller: widget.controller,
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
            suffixIconColor: Colors.black,
            labelStyle: const TextStyle(color: Colors.black),
            filled: true,
            fillColor: Colors.white,
            labelText: widget.title,
            suffixIcon: InkWell(
              onTap: () {
                setState(() { showPassword = !showPassword; });
              },
              child: (showPassword)
                ? const Icon(Icons.visibility)
                : const Icon(Icons.visibility_off),
            ),
          ),
        ),
      ),
    );
  }
}
