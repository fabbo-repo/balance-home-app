import 'package:flutter/material.dart';

class SimpleTextField extends StatelessWidget {
  
  final String title;

  final TextEditingController textFieldController;

  const SimpleTextField({
    required this.title,
    required this.textFieldController,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        controller: textFieldController,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: title,
        ),
      ),
    );
  }
}