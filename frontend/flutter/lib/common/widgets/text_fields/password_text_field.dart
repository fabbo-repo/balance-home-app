import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {
  final String title;

  final TextEditingController textFieldController;

  const PasswordTextField(
      {required this.title, required this.textFieldController, Key? key})
      : super(key: key);

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        obscureText: !showPassword,
        controller: widget.textFieldController,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
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
    );
  }
}
