import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DropdownPickerField extends StatefulWidget {
  final String name;
  final List<String> items;
  final void Function(String?)? onChanged;
  String initialValue;

  DropdownPickerField({
    required this.name,
    required this.initialValue,
    required this.items,
    this.onChanged,
    super.key
  });

  @override
  State<DropdownPickerField> createState() => _DropdownPickerFieldState();
}

class _DropdownPickerFieldState extends State<DropdownPickerField> {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 15, 0, 20),
        width: 200,
        color: const Color.fromARGB(105, 163, 163, 163),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children : [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 18, 0),
              child: Text(
                widget.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black, 
                  fontSize: 15
                ),
              ),
            ),
            DropdownButton<String>(
              value: widget.initialValue,
              onChanged: (String? value) {
                setState(() {
                  if (widget.onChanged != null) {
                    widget.onChanged!(value);
                  }
                  widget.initialValue = value!;
                });
              },
              items: widget.items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ]
        ),
      ),
    );
  }
}