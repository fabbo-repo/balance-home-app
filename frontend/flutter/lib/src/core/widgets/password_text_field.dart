import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {
  final String title;

  final TextEditingController controller;

  final String? error;

  final Function(String)? onChanged;


  const PasswordTextField({
    required this.title, 
    required this.controller,
    this.error,
    this.onChanged,
    Key? key
  }) : super(key: key);

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 700),
            padding: const EdgeInsets.all(10),
            child: TextField(
              obscureText: !showPassword,
              onChanged: widget.onChanged,
              controller: widget.controller,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: 
                    (widget.error != null && widget.error != "") ?
                      BorderSide(color: Colors.red):
                      BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: 
                    (widget.error != null && widget.error != "") ?
                      BorderSide(color: Colors.red):
                      BorderSide(color: Colors.blue),
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
          Text(
            widget.error ?? "",
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